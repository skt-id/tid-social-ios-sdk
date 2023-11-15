import Foundation
import TidLib
import NaverThirdPartyLogin
 
/// 네이버 로그인 SDK
public class TidSocialNaverSDK : NSObject, TidSocialSDK, NaverThirdPartyLoginConnectionDelegate {
    var kServiceAppUrlScheme    = "" // 콜백을 받을 URL Scheme(회원플랫폼팀 전용)
    var kConsumerKey            = "" // 애플리케이션에서 사용하는 클라이언트 아이디
    var kConsumerSecret         = "" // 애플리케이션에서 사용하는 클라이언트 시크릿
    var kServiceAppName         = "" // 애플리케이션 이름
     
    let naverConn : NaverThirdPartyLoginConnection = NaverThirdPartyLoginConnection.getSharedInstance()
    var completionHandler: ((Result<TidLib.TidSocialToken, Error>) -> Void)?
    var isInit = false
     
    public convenience init(appUrlScheme: String, consumerKey: String, consumerSecret: String, appName: String) {
        self.init()
        self.kServiceAppUrlScheme = appUrlScheme
        self.kConsumerKey = consumerKey
        self.kConsumerSecret = consumerSecret
        self.kServiceAppName = appName
    }
    
    public func initSDK(serverType: TidServerHost) {
        naverConn.isNaverAppOauthEnable = true
        naverConn.isInAppOauthEnable = true
        naverConn.serviceUrlScheme = kServiceAppUrlScheme
        naverConn.consumerKey = kConsumerKey
        naverConn.consumerSecret = kConsumerSecret
        naverConn.appName = kServiceAppName
        
        isInit = true
    }
    
    public func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return NaverThirdPartyLoginConnection.getSharedInstance().application(app, open: url, options: [:])
    }
    
    public func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        NaverThirdPartyLoginConnection.getSharedInstance().scene(scene, openURLContexts: URLContexts)
    }
     
    public func login(completion: @escaping (Result<TidLib.TidSocialToken, Error>) -> Void) {
        naverConn.resetToken()
        naverConn.delegate = self
        naverConn.requestThirdPartyLogin()
        completionHandler = completion
    }
     
    func tokenCallback(error: Error? = nil) {
        if let error = error {
            completionHandler?(.failure(error))
        } else {
            let token = TidSocialToken(accessToken: naverConn.accessToken, refreshToken: naverConn.refreshToken)
            completionHandler?(.success(token))
        }
        self.completionHandler = nil
    }
     
    // NaverThirdPartyLoginConnectionDelegate
    public func oauth20ConnectionDidFinishRequestACTokenWithAuthCode() {
        // 인앱, 앱2앱 로그인 성공
        debugPrint("oauth20ConnectionDidFinishRequestACTokenWithAuthCode")
        tokenCallback()
    }
     
    public func oauth20ConnectionDidFinishRequestACTokenWithRefreshToken() {
        // 토큰 갱신 성공
        debugPrint("oauth20ConnectionDidFinishRequestACTokenWithRefreshToken")
        tokenCallback()
    }
     
    public func oauth20ConnectionDidFinishDeleteToken() {
        debugPrint("oauth20ConnectionDidFinishDeleteToken")
    }
     
    public func oauth20Connection(_ oauthConnection: NaverThirdPartyLoginConnection!, didFailWithError error: Error!) {
        // 로그인 실패
        debugPrint("oauth20Connection(oauthConnection:didFailWithError")
        if let nsError = error as? NSError,
           nsError.code == 3 { // access_denied
            tokenCallback(error: TidError.ERROR_USER_CANCEL)
        } else {
            tokenCallback(error: error)
        }
    }
     
    public func oauth20Connection(_ oauthConnection: NaverThirdPartyLoginConnection!, didFailAuthorizationWithReceive receiveType: THIRDPARTYLOGIN_RECEIVE_TYPE) {
        debugPrint("oauth20Connection(oauthConnection:didFailAuthorizationWithReceive")
        if receiveType == CANCELBYUSER {
            tokenCallback(error: TidError.ERROR_USER_CANCEL)
        }
    }
     
    public func oauth20Connection(_ oauthConnection: NaverThirdPartyLoginConnection!, didFinishAuthorizationWithResult receiveType: THIRDPARTYLOGIN_RECEIVE_TYPE) {
        debugPrint("oauth20Connection(oauthConnection:didFinishAuthorizationWithResult")
    }
}

