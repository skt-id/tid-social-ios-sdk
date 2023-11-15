import Foundation
import UIKit
import TidLib
import KakaoSDKCommon
import KakaoSDKAuth
import KakaoSDKUser

/// 카카오 로그인 SDK
public class TidSocialKakaoSDK : NSObject, TidSocialSDK {
    var nativeAppKeys: [TidServerHost: String] = [:]
    var isInit = false
    
    public convenience init(nativeAppKeys: [TidServerHost: String]) {
        self.init()
        self.nativeAppKeys = nativeAppKeys;
    }
    
    public func initSDK(serverType: TidServerHost) {
        if let key = nativeAppKeys[serverType] {
            KakaoSDK.initSDK(appKey: key)
            isInit = true
        } else {
            fatalError()
        }
        
    }
     
    public func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        return isInit && AuthApi.isKakaoTalkLoginUrl(url) && AuthController.handleOpenUrl(url: url)
    }
    
    public func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        if isInit, let url = URLContexts.first?.url {
            if (AuthApi.isKakaoTalkLoginUrl(url)) {
                _ = AuthController.handleOpenUrl(url: url)
            }
        }
    }
    
    public func login(completion: @escaping (Result<TidLib.TidSocialToken, Error>) -> Void) {
        let completionHandler: (OAuthToken?, Error?) -> Void = { (oauthToken, error) in
            if let error = error {
                debugPrint(error)
                if let kakaoError = error as? KakaoSDKCommon.SdkError, case let .ClientFailed(reason, _) = kakaoError, reason == .Cancelled {
                    // 카톡 동의 화면에서 우상단 X 버튼
                    completion(.failure(TidError.ERROR_USER_CANCEL))
                } else if let kakaoError = error as? KakaoSDKCommon.SdkError, case let .AuthFailed(reason, _) = kakaoError, reason == .AccessDenied {
                    // 카톡 동의 화면에서 하단 취소 버튼
                    completion(.failure(TidError.ERROR_USER_CANCEL))
                } else {
                    completion(.failure(error))
                }
            }
            else {
                let token = TidSocialToken(accessToken: oauthToken?.accessToken ?? "", refreshToken: oauthToken?.refreshToken ?? "")
                completion(.success(token))
            }
        }
         
        // 카카오톡 실행 가능 여부 확인
        if (UserApi.isKakaoTalkLoginAvailable()) {
            debugPrint("isKakaoTalkLoginAvailable()")
            UserApi.shared.loginWithKakaoTalk(completion: completionHandler)
        } else {
            debugPrint("loginWithKakaoAccount()")
            UserApi.shared.loginWithKakaoAccount(completion: completionHandler)
        }
    }
}
