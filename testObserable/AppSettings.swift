

import Foundation

class AppSettings: NSObject {
	
	enum Language: String {
		case Chinese = "zh"
		case English = "en"
		
		var code: String {
			return rawValue
		}
		
		var display: String {
			switch self {
			case .Chinese:
				return "中文"
			case .English:
				return "English"
			}
		}
	}

    let stuObservable: Observable<Stu>
    let stusObservable: Observable<[Stu]>
    
    let observableLanguage: Observable<Language>
    var language: Language {
        get {
            return observableLanguage.value
        }
        set {
            observableLanguage.value = newValue
        }
    }
	
	override init() {
        
        // init
        let language: Language =  .Chinese
        /// init
        observableLanguage = Observable(language)
        
        let stu = Stu(name: "lili", age: 4324)
        stuObservable = Observable(stu)
        
        let stus = [Stu(name: "Jason", age: 44)]
        stusObservable = Observable(stus)
        
		super.init()
	}
    
	fileprivate static let kSharedSettingsKey = "defaultUserSettings"
    
	static let shared: AppSettings = {
		let appSettings: AppSettings
		if let savedData = UserDefaults.standard.object(forKey: AppSettings.kSharedSettingsKey) as? Data,
			let defaultSettings = NSKeyedUnarchiver.unarchiveObject(with: savedData) as? AppSettings{
			appSettings = defaultSettings
		} else {
			appSettings = AppSettings()
		}
		
		return appSettings
	}()
	
	static func saveSharedInstance() {
		let data = NSKeyedArchiver.archivedData(withRootObject: AppSettings.shared)
		UserDefaults.standard.set(data, forKey: AppSettings.kSharedSettingsKey)
	}
    
}
