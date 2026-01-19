import Foundation

class LocalStorage {
    static let shared = LocalStorage()
    private let userDefaults = UserDefaults.standard
    private let emotionKey = "fengleme_emotions"
    private let favoriteKey = "fengleme_favorites"
    
    // 保存情绪记录
    func saveEmotion(tag: String, voicePath: String) {
        var emotions = getEmotions()
        let emotionDict: [String: Any] = [
            "tag": tag,
            "voicePath": voicePath,
            "timeStamp": Date().timeIntervalSince1970,
            "dateStr": getDateStr()
        ]
        emotions.append(emotionDict)
        userDefaults.set(emotions, forKey: emotionKey)
    }
    
    // 获取所有情绪
    func getEmotions() -> [[String: Any]] {
        return userDefaults.array(forKey: emotionKey) as? [[String: Any]] ?? []
    }
    
    // 获取有记录的日期
    func getRecordDates() -> [String] {
        let allEmotions = getEmotions()
        let dateSet = Set(allEmotions.compactMap { $0["dateStr"] as? String })
        return Array(dateSet).sorted()
    }
    
    // 按日期查询情绪
    func getEmotionsByDate(_ dateStr: String) -> [[String: Any]] {
        let allEmotions = getEmotions()
        return allEmotions.filter { $0["dateStr"] as? String == dateStr }
    }
    
    // 删除指定日期的记录
    func deleteEmotion(at index: Int, for dateStr: String) {
        var emotions = getEmotionsByDate(dateStr)
        guard index < emotions.count else { return }
        emotions.remove(at: index)
        
        let allEmotions = getEmotions().filter { $0["dateStr"] as? String != dateStr } + emotions
        userDefaults.set(allEmotions, forKey: emotionKey)
    }
    
    // 收藏情绪
    func addFavorite(emotionDict: [String: Any]) {
        var favorites = getFavorites()
        favorites.append(emotionDict)
        userDefaults.set(favorites, forKey: favoriteKey)
    }
    
    // 获取收藏列表
    func getFavorites() -> [[String: Any]] {
        return userDefaults.array(forKey: favoriteKey) as? [[String: Any]] ?? []
    }
    
    // 辅助：获取当前日期字符串
    private func getDateStr() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }
}