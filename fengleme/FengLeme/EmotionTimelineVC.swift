import UIKit
import AVFoundation

class EmotionTimelineVC: UIViewController {
    // MARK: - 界面元素
    let calendarView = EmotionCalendarView()
    let recordTableView = UITableView()
    var selectedDate: String = ""
    var currentEmotions: [[String: Any]] = []
    var audioPlayer: AVAudioPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupData()
    }
    
    // MARK: - UI 搭建
    func setupUI() {
        view.backgroundColor = .white
        title = "我的情绪时光轴"
        edgesForExtendedLayout = []
        
        // 1. 日历视图
        calendarView.frame = CGRect(x: 0, y: 20, width: view.bounds.width, height: 200)
        calendarView.onDateSelected = { [weak self] dateStr in
            guard let self = self else { return }
            self.selectedDate = dateStr
            self.currentEmotions = LocalStorage.shared.getEmotionsByDate(dateStr)
            self.recordTableView.reloadData()
        }
        view.addSubview(calendarView)
        
        // 2. 记录列表
        recordTableView.frame = CGRect(x: 0, y: 220, width: view.bounds.width, height: view.bounds.height - 220)
        recordTableView.register(UITableViewCell.self, forCellReuseIdentifier: "EmotionCell")
        recordTableView.dataSource = self
        recordTableView.delegate = self
        view.addSubview(recordTableView)
        
        // 空状态提示
        let emptyLabel = UILabel(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 100))
        emptyLabel.text = "还没有归档情绪，今天来疯一次吧～"
        emptyLabel.textAlignment = .center
        emptyLabel.textColor = .gray
        recordTableView.backgroundView = emptyLabel
    }
    
    // MARK: - 数据初始化
    func setupData() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        selectedDate = dateFormatter.string(from: Date())
        calendarView.setRecordDates(LocalStorage.shared.getRecordDates())
        currentEmotions = LocalStorage.shared.getEmotionsByDate(selectedDate)
    }
    
    // MARK: - 播放录音
    func playVoice(path: String, voiceType: Int = 0) {
        let url = URL(fileURLWithPath: path)
        audioPlayer = try? AVAudioPlayer(contentsOf: url)
        switch voiceType {
        case 1: audioPlayer?.rate = 0.7
        case 2: audioPlayer?.rate = 1.5
        case 3: audioPlayer?.rate = 2.0
        default: audioPlayer?.rate = 1.0
        }
        audioPlayer?.play()
    }
}

// MARK: - 列表数据源&代理
extension EmotionTimelineVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = currentEmotions.count
        tableView.backgroundView?.isHidden = count > 0
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EmotionCell", for: indexPath)
        let emotion = currentEmotions[indexPath.row]
        let tag = emotion["tag"] as! String
        let timeStamp = TimeInterval(emotion["timeStamp"] as! Double)
        let time = DateFormatter.localizedString(from: Date(timeIntervalSince1970: timeStamp), dateStyle: .none, timeStyle: .short)
        
        cell.textLabel?.text = "[\(time)] \(tag)"
        cell.textLabel?.font = UIFont.systemFont(ofSize: 16)
        
        // 收藏+删除按钮
        let favoriteBtn = UIButton(type: .system)
        favoriteBtn.setImage(UIImage(systemName: "star"), for: .normal)
        favoriteBtn.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        favoriteBtn.addTarget(self, action: #selector(favoriteBtnTapped(_:)), for: .touchUpInside)
        favoriteBtn.tag = indexPath.row
        
        let deleteBtn = UIButton(type: .system)
        deleteBtn.setImage(UIImage(systemName: "trash"), for: .normal)
        deleteBtn.frame = CGRect(x: 40, y: 0, width: 30, height: 30)
        deleteBtn.addTarget(self, action: #selector(deleteBtnTapped(_:)), for: .touchUpInside)
        deleteBtn.tag = indexPath.row
        deleteBtn.tintColor = .red
        
        let stackView = UIStackView(arrangedSubviews: [favoriteBtn, deleteBtn])
        stackView.axis = .horizontal
        stackView.spacing = 10
        cell.accessoryView = stackView
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let emotion = currentEmotions[indexPath.row]
        let voicePath = emotion["voicePath"] as! String
        playVoice(path: voicePath)
    }
    
    @objc func favoriteBtnTapped(_ sender: UIButton) {
        let emotion = currentEmotions[sender.tag]
        LocalStorage.shared.addFavorite(emotionDict: emotion)
        showAlert(title: "成功", message: "已加入收藏夹～")
    }
    
    @objc func deleteBtnTapped(_ sender: UIButton) {
        let alert = UIAlertController(title: "提示", message: "删除后无法恢复，确定吗？", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        alert.addAction(UIAlertAction(title: "删除", style: .destructive, handler: { [weak self] _ in
            guard let self = self else { return }
            let emotion = self.currentEmotions[sender.tag]
            let voicePath = emotion["voicePath"] as! String
            try? FileManager.default.removeItem(atPath: voicePath)
            LocalStorage.shared.deleteEmotion(at: sender.tag, for: self.selectedDate)
            self.currentEmotions.remove(at: sender.tag)
            self.recordTableView.reloadData()
            self.calendarView.setRecordDates(LocalStorage.shared.getRecordDates())
        }))
        present(alert, animated: true)
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default))
        present(alert, animated: true)
    }
}