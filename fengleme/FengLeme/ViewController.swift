import UIKit

class ViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBar()
        setupGlobalNavigation()
    }
    
    // 配置全局导航栏（所有页面左上角显示Logo）
    func setupGlobalNavigation() {
        let logoLabel = UILabel()
        logoLabel.text = "疯了么"
        logoLabel.font = UIFont.boldSystemFont(ofSize: 18)
        logoLabel.textColor = .red
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: logoLabel)
        navigationItem.leftBarButtonItem?.isEnabled = false // 纯展示，不可点击
    }
    
    // 配置底部TabBar
    func setupTabBar() {
        tabBar.tintColor = .orange // 选中颜色
        tabBar.barTintColor = .white // 背景色
        tabBar.layer.shadowColor = UIColor.gray.cgColor
        tabBar.layer.shadowOpacity = 0.1
        tabBar.layer.shadowOffset = CGSize(width: 0, height: -2)
        
        // 1. 首页：情绪归档
        let archiveVC = EmotionArchiveVC()
        let archiveItem = UITabBarItem(
            title: "首页",
            image: UIImage(systemName: "house"),
            selectedImage: UIImage(systemName: "house.fill")
        )
        archiveVC.tabBarItem = archiveItem
        let archiveNav = UINavigationController(rootViewController: archiveVC)
        
        // 2. 情绪池：匿名打捞
        let roamVC = EmotionRoamVC()
        let roamItem = UITabBarItem(
            title: "情绪池",
            image: UIImage(systemName: "bubble.left.and.bubble.right"),
            selectedImage: UIImage(systemName: "bubble.left.and.bubble.right.fill")
        )
        roamVC.tabBarItem = roamItem
        let roamNav = UINavigationController(rootViewController: roamVC)
        
        // 3. 消息中心：互动通知
        let messageVC = MessageVC()
        let messageItem = UITabBarItem(
            title: "消息",
            image: UIImage(systemName: "envelope"),
            selectedImage: UIImage(systemName: "envelope.fill")
        )
        messageVC.tabBarItem = messageItem
        let messageNav = UINavigationController(rootViewController: messageVC)
        
        // 4. 我的：情绪时光轴
        let timelineVC = EmotionTimelineVC()
        let timelineItem = UITabBarItem(
            title: "我的",
            image: UIImage(systemName: "person"),
            selectedImage: UIImage(systemName: "person.fill")
        )
        timelineVC.tabBarItem = timelineItem
        let timelineNav = UINavigationController(rootViewController: timelineVC)
        
        viewControllers = [archiveNav, roamNav, messageNav, timelineNav]
    }
}