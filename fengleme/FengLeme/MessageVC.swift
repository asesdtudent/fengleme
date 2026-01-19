import UIKit

// 消息模型
struct EmotionMessage {
    var type: MessageType
    var content: String
    var time: String
}

// 消息类型枚举
enum MessageType {
    case fish       // 被打捞
    case resonance  // 情绪共鸣
    case tip        // 每日小贴士
}

class MessageVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - 界面元素
    let messageTableView = UITableView()
    var messageList: [EmotionMessage] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadMockMessages()
    }
    
    // MARK: - UI 搭建
    func setupUI() {
        view.backgroundColor = .white
        title = "消息中心"
        edgesForExtendedLayout = []
        
        // 消息列表
        messageTableView.frame = view.bounds
        messageTableView.register(MessageCell.self, forCellReuseIdentifier: "MessageCell")
        messageTableView.dataSource = self
        messageTableView.delegate = self
        messageTableView.separatorStyle = .none
        view.addSubview(messageTableView)
    }
    
    // MARK: - 加载模拟消息
    func loadMockMessages() {
        messageList = [
            EmotionMessage(type: .fish, content: "你的「摆烂」情绪被 3 人打捞啦～", time: "今天 10:23"),
            EmotionMessage(type: .resonance, content: "有 2 人和你一样「CPU 烧了」，找到病友啦！", time: "昨天 18:05"),
            EmotionMessage(type: .tip, content: "每日小贴士：发疯是正常的情绪出口，不用不好意思～", time: "昨天 08:00"),
            EmotionMessage(type: .fish, content: "你的「已黑化」情绪气泡被收藏 1 次", time: "3 天前")
        ]
    }
    
    // MARK: - 列表数据源
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath) as! MessageCell
        cell.configCell(message: messageList[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}

// MARK: - 自定义消息单元格
class MessageCell: UITableViewCell {
    
    let iconView = UIImageView()
    let contentLabel = UILabel()
    let timeLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCellUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 搭建单元格UI
    func setupCellUI() {
        backgroundColor = .white
        
        // 图标
        iconView.frame = CGRect(x: 20, y: 20, width: 40, height: 40)
        iconView.layer.cornerRadius = 20
        iconView.clipsToBounds = true
        contentView.addSubview(iconView)
        
        // 内容
        contentLabel.frame = CGRect(x: 70, y: 15, width: contentView.bounds.width - 120, height: 30)
        contentLabel.font = UIFont.systemFont(ofSize: 15)
        contentLabel.textColor = .black
        contentView.addSubview(contentLabel)
        
        // 时间
        timeLabel.frame = CGRect(x: 70, y: 45, width: contentView.bounds.width - 120, height: 20)
        timeLabel.font = UIFont.systemFont(ofSize: 12)
        timeLabel.textColor = .gray
        contentView.addSubview(timeLabel)
    }
    
    // 配置单元格数据
    func configCell(message: EmotionMessage) {
        contentLabel.text = message.content
        timeLabel.text = message.time
        
        switch message.type {
        case .fish:
            iconView.image = UIImage(systemName: "hook")
            iconView.tintColor = .orange
            iconView.backgroundColor = .orange.withAlphaComponent(0.2)
        case .resonance:
            iconView.image = UIImage(systemName: "heart.fill")
            iconView.tintColor = .systemPink
            iconView.backgroundColor = .systemPink.withAlphaComponent(0.2)
        case .tip:
            iconView.image = UIImage(systemName: "lightbulb.fill")
            iconView.tintColor = .systemBlue
            iconView.backgroundColor = .systemBlue.withAlphaComponent(0.2)
        }
    }
}