
import UIKit
import RevealingSplashView
import Social
import MobileCoreServices
import SafariServices
import TwitterKit

import TwitterCore

class ViewController: UIViewController, TWTRComposerViewControllerDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate,TWTRTweetViewDelegate{
    var tweetView: [TWTRTweet] = [] {
        didSet {

        }
    }
     var loginbutton : TWTRLogInButton!
     let composer = TWTRComposer()
     let picker = UIImagePickerController()
     var pickerController: UIImagePickerController = UIImagePickerController()
    
    @IBOutlet weak var tweetimg: UIImageView!
    @IBOutlet weak var userprofilename: UILabel!
    @IBOutlet weak var profilename: UILabel!
    @IBOutlet weak var profileimageviewer: UIImageView!
    
    var isLoadingTweets = false
   let tweetIDs = ["20", "510908133917487104"]
    let client = TWTRAPIClient()
    
    
    let statusesShowEndpoint = "https://api.twitter.com/1.1/statuses/show.json"
    let params = ["id": "20"]
    var clientError : NSError?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let revealingSplashView = RevealingSplashView(iconImage: UIImage(named: "launch")!,iconInitialSize: CGSize(width: 70, height: 70), backgroundColor: UIColor(red:0.11, green:0.56, blue:0.95, alpha:1.0))
        
        //Adds the revealing splash view as a sub view
        self.view.addSubview(revealingSplashView)
        
        //Starts animation
        revealingSplashView.startAnimation(){
            print("Completed")
        }

//        REACHABLITY CONCEPT
        if Reachability.isConnectedToNetwork() == true {
            print("Internet connection OK")
        } else {
            print("Internet connection FAILED")
            var alert = UIAlertView(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
        }
//    BELOW CODE MAIN  BUTTON AND I LL ADDING  MY CONCEPT IN  MAIN USER NAME VIEWING
        loginbutton = TWTRLogInButton{(session,error)in
            if let Unwrappedsission = session{
                let client = TWTRAPIClient()
                client.loadUser(withID: (Unwrappedsission.userID), completion: { (user, error) in
                    self.userprofilename.text = user?.name
                    self.profilename.text = Unwrappedsission.userName

                    let imgurl = user?.profileImageURL
                    let url = URL(string:imgurl!)
                    let data = try?Data (contentsOf: url!)
                    self.profileimageviewer.image = UIImage(data: data!)
                })
                
            }
            else {
                print("login Error")
            }
        }
        
        self.loginbutton.center = self.view.center
        self.view.addSubview(self.loginbutton)
        TWTRTwitter.sharedInstance().logIn(with: self, completion: { (session, error) in
            
            if let sess = session {
                print("signed in as \(sess.userName)");
            } else {
                print("error: \(String(describing: error?.localizedDescription))");
            }
        })
        TWTRTwitter.sharedInstance().logIn(completion: { (session, error) in
            if (session != nil) {
                print("signed in as \(session?.userName)");
            } else {
                print("error: \(error?.localizedDescription)");
            }
        })

        TWTRTwitter.sharedInstance().sessionStore.fetchGuestSession { (guestSession, error) in
            if (guestSession != nil) {
            } else {
                print("error: \(error)");
            }
        }
       

//         BELOW CODE LOGGING ALERT

        if (TWTRTwitter.sharedInstance().sessionStore.hasLoggedInUsers()) {
            let composer = TWTRComposerViewController.emptyComposer()
            present(composer, animated: true, completion: nil)
        } else {
            TWTRTwitter.sharedInstance().logIn { session, error in
                if session != nil { // Log in succeeded
                    let composer = TWTRComposerViewController.emptyComposer()
                    self.present(composer, animated: true, completion: nil)
                } else {
//                    let alert = UIAlertController(title: "No Twitter Accounts Available", message: "You must log in before presenting a composer.", preferredStyle: .alert)
//                    self.present(alert, animated: false, completion: nil)
                }
            }
        }
        if(TWTRTwitter.sharedInstance().sessionStore.hasLoggedInUsers()){
            self.composer
        }else{
            TWTRTwitter.sharedInstance().logIn {
                (session, error) -> Void in
                if (session != nil) {
                    
                    print(session!.userID)
                    print(session!.userName)
                    print(session!.authToken)
                    print(session!.authTokenSecret)
                    self.composer
                    
                    
                }else {
                    print("Not Login")
                }
            }
            
        }
        if let userID = TWTRTwitter.sharedInstance().sessionStore.session()?.userID {
            let client = TWTRAPIClient(userID: userID)
            // make requests with client
        }
        client.loadTweet(withID: "20") { (tweet, error) -> Void in
            // handle the response or error
        }
        client.loadTweets(withIDs: tweetIDs) { (tweets, error) -> Void in
            // handle the response or error
        }
        client.loadUser(withID: "12") { (user, error) -> Void in
            // handle the response or error
        }
        
    }

//     below code is i ll adding  own tweet (with loging twitter )
    @IBAction func choosebutton(_ sender: Any) {
        pickerController.delegate = self
        pickerController.sourceType = UIImagePickerControllerSourceType.photoLibrary
        self.present(pickerController, animated: true, completion: nil)
}
    
    @IBAction func Tweetbutton(_ sender: Any) {
        if SLComposeViewController.isAvailable(forServiceType: SLServiceTypeTwitter) {
            let tweetSheet = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
if let tweetSheet = tweetSheet {
                tweetSheet.setInitialText("Look at this nice picture!")
                tweetSheet.add(tweetimg.image)
                self.present(tweetSheet, animated: true, completion: nil)
            }
        } else {
            print("error")
            }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
            tweetimg.image = info[UIImagePickerControllerOriginalImage] as? UIImage
            
            self.dismiss(animated: true, completion: nil)
        }
        
        }
    
    func presentImagePicker() {
        let picker = UIImagePickerController()
        picker.delegate = self as! UIImagePickerControllerDelegate & UINavigationControllerDelegate
        picker.mediaTypes = [String(kUTTypeImage), String(kUTTypeMovie)]
        present(picker, animated: true, completion: nil)
    }
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        // Dismiss the image picker
        dismiss(animated: true, completion: nil)
        
        // Grab the relevant data from the image picker info dictionary
        let image = info[UIImagePickerControllerOriginalImage] as? UIImage
        let fileURL = info[UIImagePickerControllerMediaURL] as? URL
        
        // Create the composer
        let composer = TWTRComposerViewController(initialText: "Check out this great image: ", image: image, videoURL:fileURL)
        composer.delegate = self
        present(composer, animated: true, completion: nil)
    }
    func composerDidCancel(_ controller: TWTRComposerViewController) {
        print("composerDidCancel, composer cancelled tweet")
    }
    
    func composerDidSucceed(_ controller: TWTRComposerViewController, with tweet: TWTRTweet) {
        print("composerDidSucceed tweet published")
    }
    func composerDidFail(_ controller: TWTRComposerViewController, withError error: Error) {
        print("composerDidFail, tweet publish failed == \(error.localizedDescription)")
    }
    

}
