import UIKit
import AVFoundation

class EmotionRoamVC: UIViewController {
    // MARK: - 界面元素
    let emotionCardView = UIView()
    let tagBadge = UILabel()
    let voiceWaveView = UIImageView()
    let favoriteButton = UIButton()
    let likeBtn = UIButton()    // 懂你
    let shockBtn = UIButton()   // 扎心
    let laughBtn = UIButton()   // 笑疯
    
    // MARK: - 数据
    var allEmotions: [[String: Any]] = []
    var currentIndex = 0
    var audioPlayer: AVAudioPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadMockData()
        showCurrentEmotion()
        setupSwipeGesture()
    }
    
    // MARK: - UI 搭建
    func setupUI() {
        view.backgroundColor = .white
        title = "情绪池"
        edgesForExtendedLayout = []
        
        // 1. 情绪卡片
        emotionCardView.frame = CGRect(x: 20, y: 20, width: view.bounds.width - 40, height: 300)
        emotionCardView.layer.cornerRadius = 16
        emotionCardView.backgroundColor = .white
        emotionCardView.layer.shadowColor = UIColor.gray.cgColor
        emotionCardView.layer.shadowOpacity = 0.3
        emotionCardView.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.addSubview(emotionCardView)
        
        // 2. 标签徽章
        tagBadge.frame = CGRect(x: 20, y: 20, width: 80, height: 30)
        tagBadge.text = "躁狂症"
        tagBadge.textAlignment = .center
        tagBadge.font = UIFont.boldSystemFont(ofSize: 14)
        tagBadge.textColor = .white
        tagBadge.backgroundColor = .orange
        tagBadge.layer.cornerRadius = 15
        tagBadge.clipsToBounds = true
        emotionCardView.addSubview(tagBadge)
        
        // 3. 声波图
        voiceWaveView.frame = CGRect(x: 40, y: 70, width: emotionCardView.bounds.width - 80, height: 100)
        voiceWaveView.image = UIImage(systemName: "waveform")
        voiceWaveView.tintColor = .gray
        voiceWaveView.contentMode = .scaleAspectFit
        emotionCardView.addSubview(voiceWaveView)
        
        // 4. 收藏按钮
        favoriteButton.frame = CGRect(x: emotionCardView.bounds.width - 40, y: 20, width: 30, height: 30)
        favoriteButton.setImage(UIImage(systemName: "star"), for: .normal)
        favoriteButton.tintColor = .orange
        favoriteButton.isHidden = true
        favoriteButton.addTarget(self, action: #selector(favoriteTapped), for: .touchUpInside)
        emotionCardView.addSubview(favoriteButton)
        
        // 5. 互动按钮
        likeBtn.frame = CGRect(x: 20, y: 350, width: 80, height: 44)
        likeBtn.setTitle("懂你 💊", for: .normal)
        likeBtn.backgroundColor = .systemGreen
        likeBtn.layer.cornerRadius = 22
        likeBtn.addTarget(self, action: #selector(interactTapped), for: .touchUpInside)
        view.addSubview(likeBtn)
        
        shockBtn.frame = CGRect(x: view.bounds.width/2 - 40, y: 350, width: 80, height: 44)
        shockBtn.setTitle("扎心 ⚡", for: .normal)
        shockBtn.backgroundColor = .systemYellow
        shockBtn.layer.cornerRadius = 22
        shockBtn.addTarget(self, action: #selector(interactTapped), for: .touchUpInside)
        view.addSubview(shockBtn)
        
        laughBtn.frame = CGRect(x: view.bounds.width - 100, y: 350, width: 80, height: 44)
        laughBtn.setTitle("笑疯 🔥", for: .normal)
        laughBtn.backgroundColor = .systemRed
        laughBtn.layer.cornerRadius = 22
        laughBtn.addTarget(self, action: #selector(interactTapped), for: .touchUpInside)
        view.addSubview(laughBtn)
        
        // 长按显示收藏
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(cardLongPressed))
        emotionCardView.addGestureRecognizer(longPress)
        
        // 点击播放录音
        let tap = UITapGestureRecognizer(target: self, action: #selector(playCurrentVoice))
        emotionCardView.addGestureRecognizer(tap)
    }
    
    // MARK: - 数据加载
    func loadMockData() {
        allEmotions = [
            ["tag": "躁狂症", "voicePath": NSTemporaryDirectory() + "mock1.m4a", "nickname": "隔壁工位怨种"],
            ["tag": "摆烂症", "voicePath": NSTemporaryDirectory() + "mock2.m4a", "nickname": "凌晨三点修仙党"],
            ["tag": "已黑化", "voicePath": NSTemporaryDirectory() + "mock3.m4a", "nickname": "咖啡续命选手"],
            ["tag": "被迫害妄想", "voicePath": NSTemporaryDirectory() + "mock4.m4a", "nickname": "摸鱼一级选手"]
        ]
    }
    
    // MARK: - 显示当前情绪
    func showCurrentEmotion() {
        guard currentIndex < allEmotions.count else {
            currentIndex = 0
        }
        let emotion = allEmotions[currentIndex]
        tagBadge.text = emotion["tag"] as? String
        voiceWaveView.image = UIImage(systemName: "waveform")
        favoriteButton.isHidden = true
    }
    
    // MARK: - 手势配置
    func setupSwipeGesture() {
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(swipeToNext))
        swipeUp.direction = .up
        view.addGestureRecognizer(swipeUp)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(swipeToNext))
        swipeLeft.direction = .left
        view.addGestureRecognizer(swipeLeft)
    }
    
    // MARK: - 事件处理
    @objc func cardLongPressed() {
        favoriteButton.isHidden = !favoriteButton.isHidden
    }
    
    @objc func favoriteTapped() {
        let emotion = allEmotions[currentIndex]
        LocalStorage.shared.addFavorite(emotionDict: emotion)
        showAlert(title: "成功", message: "已加入情绪收藏夹～")
    }
    
    @objc func playCurrentVoice() {
        let emotion = allEmotions[currentIndex]
        let voicePath = emotion["voicePath"] as! String
        audioPlayer = try? AVAudioPlayer(contentsOf: URL(fileURLWithPath: voicePath))
        audioPlayer?.play()
        voiceWaveView.image = UIImage(systemName: "waveform.fill")
    }
    
    @objc func interactTapped() {
        swipeToNext()
    }
    
    @objc func swipeToNext() {
        currentIndex += 1
        showCurrentEmotion()
        let animation = CABasicAnimation(keyPath: "transform.translation.y")
        animation.fromValue = 0
        animation.toValue = -view.bounds.height
        animation.duration = 0.3
        emotionCardView.layer.add(animation, forKey: "swipeUp")
    }
    
    // MARK: - 辅助方法
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default))
        present(alert, animated: true)
    }
}