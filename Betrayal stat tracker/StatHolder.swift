//
//  StatsHolderView.swift
//  Betrayal stat tracker
//
//  Created by Martin Peshevski on 6.3.21.
//

import UIKit

class StatView: UIView {
    var stat: StatValue {
        didSet {
            label.text = "\(stat.value)"
            if stat.isDeath { label.textColor = .systemRed } else { label.textColor = stat.isDefault ? .systemGreen : .systemGray2 }
            updateBorder()
        }
    }
    
    lazy var label: UILabel = {
        let l = UILabel()
        l.text = "\(stat.value)"
        if stat.isDeath { l.textColor = .systemRed } else { l.textColor = stat.isDefault ? .systemGreen : .systemGray2 }
        l.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        l.textAlignment = .center
        return l
    }()
    
    init(stat: StatValue) {
        self.stat = stat
        super.init(frame: .zero)
        addSubview(label)
        label.snp.makeConstraints { make in make.edges.equalToSuperview().inset(2) }
        updateBorder()
    }
    
    func updateBorder() {
        if stat.isSelected {
            layer.borderWidth = 1
            layer.borderColor = UIColor.systemBlue.cgColor
        } else {
            layer.borderWidth = 0
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

protocol StatHolderDelegate: AnyObject {
    func didUpdateSelected(type: StatType, selected: Int)
}

class StatHolder: UIView {
    lazy var increaseButton: UIButton = {
        let b = UIButton()
        b.backgroundColor = .systemBlue
        b.setTitle("+", for: .normal)
        b.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        b.addTarget(self, action: #selector(onIncrease), for: .touchUpInside)
        b.snp.makeConstraints { make in make.width.height.equalTo(50) }
        b.layer.cornerRadius = 10

        return b
    }()
    
    lazy var reduceButton: UIButton = {
        let b = UIButton()
        b.backgroundColor = .systemBlue
        b.setTitle("-", for: .normal)
        b.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        b.addTarget(self, action: #selector(onReduce), for: .touchUpInside)
        b.snp.makeConstraints { make in make.width.height.equalTo(50) }
        b.layer.cornerRadius = 10
        
        return b
    }()
    
    lazy var statsStack: UIStackView = {
        let s = UIStackView()
        
        s.axis = .horizontal
        s.spacing = 3
        s.distribution = .fill
        
        return s
    }()
    
    var stats = [StatValue]()
    var statViews = [StatView]()
    var delegate: StatHolderDelegate?
    let type: StatType
    
    var selected: Int {
        set {
            for (i, _) in stats.enumerated() { stats[i].isSelected = false }

            stats[newValue].isSelected = true
            update()
            delegate?.didUpdateSelected(type: type, selected: newValue)
        }
        get {
            for (i, _) in stats.enumerated() where stats[i].isSelected {
                return i
            }
            return 0
        }
    }
    lazy var titleLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        l.snp.makeConstraints { make in make.height.equalTo(18) }
        return l
    }()
    
    lazy var buttonStack: UIStackView = {
       let s = UIStackView()
        s.axis = .horizontal
        s.distribution = .fillEqually
        s.alignment = .center
        s.spacing = 10
        s.addArrangedSubview(reduceButton)
        s.addArrangedSubview(increaseButton)
        
        return s
    }()
    
    lazy var titleStatsStack: UIStackView = {
       let s = UIStackView()
        s.axis = .vertical
        s.distribution = .fill
        s.alignment = .leading
        s.spacing = 10
        s.addArrangedSubview(titleLabel)
        s.addArrangedSubview(statsStack)
        
        return s
    }()
    
    lazy var container: UIStackView = {
        let s = UIStackView()
        s.axis = .horizontal
        s.distribution = .fill
        s.spacing = 15
        
        s.addArrangedSubview(titleStatsStack)
        s.addArrangedSubview(UIView())
        s.addArrangedSubview(buttonStack)

        return s
    }()

    init(stats: [StatValue], type: StatType) {
        self.type = type
        super.init(frame: .zero)
        
        backgroundColor = .systemGray5
        layer.cornerRadius = 10
        layer.masksToBounds = true
        
        self.stats = stats
        self.statViews = createLabels(stats: stats)
        
        titleLabel.text = type.title
                
        for label in statViews {
            statsStack.addArrangedSubview(label)
        }
                
        addSubview(container)
        container.snp.makeConstraints { make in make.edges.equalToSuperview().inset(10) }
    }
    
    func setup(stats: [StatValue]) {
        self.stats = stats
        for (index, view) in statsStack.arrangedSubviews.enumerated() where view is StatView {
            (view as! StatView).stat = stats[index]
        }
    }
    
    func createLabels(stats: [StatValue]) -> [StatView] {
        var arr = [StatView]()
        for stat in stats { arr.append(StatView(stat: stat)) }
        
        return arr
    }
    
    func update() {
        for (i, statView) in statViews.enumerated() {
            statView.stat = stats[i]
        }
    }
    
    @objc
    func onIncrease() {
        if selected < stats.count - 1 { selected += 1 }
    }
    
    @objc
    func onReduce() {
        if selected > 0 { selected -= 1 }
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
