import UIKit

class EmotionCalendarView: UIView {
    // 选中日期回调
    var onDateSelected: ((String) -> Void)?
    
    // 界面元素
    let monthLabel = UILabel()
    let prevBtn = UIButton(type: .system)
    let nextBtn = UIButton(type: .system)
    let dateCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    
    // 数据
    let dateFormatter = DateFormatter()
    var currentMonth: Date = Date()
    var recordDates: [String] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupCalendar()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI 搭建
    func setupUI() {
        backgroundColor = .white
        
        // 月份切换按钮
        prevBtn.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        prevBtn.addTarget(self, action: #selector(prevMonth), for: .touchUpInside)
        addSubview(prevBtn)
        prevBtn.frame = CGRect(x: 20, y: 10, width: 30, height: 30)
        
        nextBtn.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        nextBtn.addTarget(self, action: #selector(nextMonth), for: .touchUpInside)
        addSubview(nextBtn)
        nextBtn.frame = CGRect(x: bounds.width - 50, y: 10, width: 30, height: 30)
        
        // 月份标题
        monthLabel.textAlignment = .center
        monthLabel.font = UIFont.boldSystemFont(ofSize: 18)
        addSubview(monthLabel)
        monthLabel.frame = CGRect(x: 50, y: 10, width: bounds.width - 100, height: 30)
        
        // 日期集合视图
        let layout = UICollectionViewFlowLayout()
        let itemWidth = (bounds.width - 7*10)/7
        layout.itemSize = CGSize(width: itemWidth, height: itemWidth)
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        
        dateCollectionView.collectionViewLayout = layout
        dateCollectionView.register(DateCell.self, forCellWithReuseIdentifier: "DateCell")
        dateCollectionView.dataSource = self
        dateCollectionView.delegate = self
        dateCollectionView.backgroundColor = .clear
        addSubview(dateCollectionView)
        dateCollectionView.frame = CGRect(x: 0, y: 50, width: bounds.width, height: bounds.height - 50)
    }
    
    // MARK: - 日历逻辑
    func setupCalendar() {
        dateFormatter.dateFormat = "yyyy年MM月"
        monthLabel.text = dateFormatter.string(from: currentMonth)
        dateCollectionView.reloadData()
    }
    
    func setRecordDates(_ dates: [String]) {
        recordDates = dates
        dateCollectionView.reloadData()
    }
    
    @objc func prevMonth() {
        currentMonth = Calendar.current.date(byAdding: .month, value: -1, to: currentMonth)!
        setupCalendar()
    }
    
    @objc func nextMonth() {
        currentMonth = Calendar.current.date(byAdding: .month, value: 1, to: currentMonth)!
        setupCalendar()
    }
    
    func getDaysInCurrentMonth() -> [Date] {
        let calendar = Calendar.current
        let range = calendar.range(of: .day, in: .month, for: currentMonth)!
        let firstDay = calendar.date(from: calendar.dateComponents([.year, .month], from: currentMonth))!
        return range.compactMap { calendar.date(byAdding: .day, value: $0 - 1, to: firstDay) }
    }
}

// MARK: - 日期单元格
class DateCell: UICollectionViewCell {
    let dateLabel = UILabel()
    let dotView = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        dateLabel.textAlignment = .center
        dateLabel.font = UIFont.systemFont(ofSize: 14)
        contentView.addSubview(dateLabel)
        dateLabel.frame = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height - 10)
        
        dotView.backgroundColor = .orange
        dotView.layer.cornerRadius = 3
        dotView.isHidden = true
        contentView.addSubview(dotView)
        dotView.frame = CGRect(x: (bounds.width - 6)/2, y: bounds.height - 8, width: 6, height: 6)
    }
}

// MARK: - 集合视图代理&数据源
extension EmotionCalendarView: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return getDaysInCurrentMonth().count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DateCell", for: indexPath) as! DateCell
        let date = getDaysInCurrentMonth()[indexPath.row]
        
        // 日期文字
        dateFormatter.dateFormat = "d"
        cell.dateLabel.text = dateFormatter.string(from: date)
        
        // 当月/非当月颜色
        let isCurrentMonth = Calendar.current.isDate(date, equalTo: currentMonth, to: .month)
        cell.dateLabel.textColor = isCurrentMonth ? .black : .lightGray
        
        // 有记录显示圆点
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateStr = dateFormatter.string(from: date)
        cell.dotView.isHidden = !recordDates.contains(dateStr)
        
        // 今天高亮
        let isToday = Calendar.current.isDateInToday(date)
        cell.contentView.backgroundColor = isToday ? .orange.withAlphaComponent(0.2) : .clear
        cell.contentView.layer.cornerRadius = cell.bounds.width/2
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let date = getDaysInCurrentMonth()[indexPath.row]
        dateFormatter.dateFormat = "yyyy-MM-dd"
        onDateSelected?(dateFormatter.string(from: date))
    }
}