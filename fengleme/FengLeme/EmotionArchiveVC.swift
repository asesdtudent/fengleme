import UIKit
import AVFoundation

class EmotionArchiveVC: UIViewController {
    // MARK: - 界面元素
    let titleLabel = UILabel()
    let userInfoLabel = UILabel()
    let tagScrollView = UIScrollView()
    let tagButtons = [UIButton(), UIButton(), UIButton(), UIButton()]
    let tagTitles = ["躁狂症", "摆烂症", "被迫害妄想", "已黑化"]
    let tagImages = ["explode", "saltfish", "ghost", "devil"]
    let recordButton = UIButton()
    let voiceChangeSegment = UISegmentedControl(items: ["原声", "大叔", "萝莉", "机器人"])
    let submitButton = UIButton()
    
    // MARK: - 录音相关
    var audioRecorder: AVAudioRecorder?
    var isRecording = false
    var selectedVoiceType = 0
    var selectedTag = "未选择" // 选中的情绪标签
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupAudioSession()
    }
    
    // MARK: - UI 搭建
    func setupUI() {
        view.backgroundColor = .white
        title = "今日情绪归档"
        edgesForExtendedLayout = [] // 适配导航栏
        
        // 1. 标题
        titleLabel.frame = CGRect(x: 20, y: 20, width: view.bounds.width - 40, height: 40)
        titleLabel.text = "我的情绪档案"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 24)
        titleLabel.textAlignment = .center
        view.addSubview(titleLabel)
        
        // 2. 用户信息
        let randomNickname = ["隔壁工位怨种", "凌晨三点修仙党", "咖啡续命选手"].randomElement()!
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let today = dateFormatter.string(from: Date())
        userInfoLabel.frame = CGRect(x: 20, y: 70, width: view.bounds.width - 40, height: 20)
        userInfoLabel.text = "用户：\(randomNickname) | 日期：\(today) | 情绪标签：\(selectedTag)"
        userInfoLabel.font = UIFont.systemFont(ofSize: 14)
        userInfoLabel.textColor = .gray
        view.addSubview(userInfoLabel)
        
        // 3. 情绪标签滚动栏
        tagScrollView.frame = CGRect(x: 20, y: 100, width: view.bounds.width - 40, height: 80)
        tagScrollView.showsHorizontalScrollIndicator = false
        tagScrollView.isPagingEnabled = false
        view.addSubview(tagScrollView)
        
        for i in 0..<4 {
            tagButtons[i].frame = CGRect(x: i*120, y: 10, width: 100, height: 60)
            tagButtons[i].setImage(UIImage(named: tagImages[i]) ?? UIImage(systemName: "tag"), for: .normal)
            tagButtons[i].setTitle(tagTitles[i], for: .normal)
            tagButtons[i].setTitleColor(.black, for: .normal)
            tagButtons[i].layer.cornerRadius = 10
            tagButtons[i].layer.borderWidth = 1
            tagButtons[i].layer.borderColor = UIColor.gray.cgColor
            tagButtons[i].addTarget(self, action: #selector(tagSelected(_:)), for: .touchUpInside)
            tagScrollView.addSubview(tagButtons[i])
        }
        tagScrollView.contentSize = CGSize(width: 4*120, height: 80)
        
        // 4. 录音按钮
        recordButton.frame = CGRect(x: view.bounds.width/2 - 50, y: 200, width: 100, height: 100)
        recordButton.setImage(UIImage(systemName: "mic.fill"), for: .normal)
        recordButton.tintColor = .red
        recordButton.layer.cornerRadius = 50
        recordButton.layer.borderWidth = 2
        recordButton.layer.borderColor = UIColor.red.cgColor
        recordButton.addTarget(self, action: #selector(recordButtonTapped), for: .touchUpInside)
        view.addSubview(recordButton)
        
        // 5. 变声选择器
        voiceChangeSegment.frame = CGRect(x: 20, y: 320, width: view.bounds.width - 40, height: 30)
        voiceChangeSegment.selectedSegmentIndex = 0
        voiceChangeSegment.addTarget(self, action: #selector(voiceTypeChanged), for: .valueChanged)
        view.addSubview(voiceChangeSegment)
        
        // 6. 提交按钮
        submitButton.frame = CGRect(x: 20, y: 380, width: view.bounds.width - 40, height: 44)
        submitButton.setTitle("归档情绪", for: .normal)
        submitButton.backgroundColor = .orange
        submitButton.layer.cornerRadius = 22
        submitButton.setTitleColor(.white, for: .normal)
        submitButton.addTarget(self, action: #selector(submitEmotion), for: .touchUpInside)
        view.addSubview(submitButton)
    }
    
    // MARK: - 按钮事件
    @objc func tagSelected(_ sender: UIButton) {
        tagButtons.forEach { $0.layer.borderColor = UIColor.gray.cgColor }
        sender.layer.borderColor = UIColor.orange.cgColor
        selectedTag = sender.titleLabel?.text ?? "未选择"
        userInfoLabel.text = userInfoLabel.text!.replacingOccurrences(of: self.selectedTag, with: selectedTag)
    }
    
    @objc func recordButtonTapped() {
        if !isRecording {
            startRecording()
            recordButton.tintColor = .systemRed
            recordButton.setImage(UIImage(systemName: "mic.slash.fill"), for: .normal)
        } else {
            stopRecording()
            recordButton.tintColor = .red
            recordButton.setImage(UIImage(systemName: "mic.fill"), for: .normal)
        }
        isRecording.toggle()
    }
    
    @objc func voiceTypeChanged() {
        selectedVoiceType = voiceChangeSegment.selectedSegmentIndex
    }
    
    @objc func submitEmotion() {
        guard selectedTag != "未选择" else {
            showAlert(title: "提示", message: "请先选择你的情绪标签～")
            return
        }
        guard let voicePath = audioRecorder?.url.path else {
            showAlert(title: "提示", message: "请先录制你的情绪～")
            return
        }
        
        // 1. 本地存储情绪
        LocalStorage.shared.saveEmotion(tag: selectedTag, voicePath: voicePath)
        
        // 2. 碎纸机动画
        let animation = CABasicAnimation(keyPath: "opacity")
        animation.fromValue = 1
        animation.toValue = 0
        animation.duration = 0.5
        titleLabel.layer.add(animation, forKey: "fadeOut")
        
        // 3. 提示并返回
        showAlert(title: "成功", message: "已归档情绪，世界清净了～") {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    // MARK: - 录音配置
    func setupAudioSession() {
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playAndRecord)
        try? session.activate(true)
    }
    
    func startRecording() {
        let tempPath = NSTemporaryDirectory() + "emotionVoice_\(UUID()).m4a"
        let url = URL(fileURLWithPath: tempPath)
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        audioRecorder = try? AVAudioRecorder(url: url, settings: settings)
        audioRecorder?.record()
    }
    
    func stopRecording() {
        audioRecorder?.stop()
        // 变声处理
        if selectedVoiceType != 0 {
            SoundEffect.shared.changeVoice(path: audioRecorder!.url.path, type: selectedVoiceType)
        }
    }
    
    // MARK: - 辅助方法
    func showAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default, handler: { _ in
            completion?()
        }))
        present(alert, animated: true)
    }
}