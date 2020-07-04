//
//  PostCreateViewController.swift
//  Spica
//
//  Created by Adrian Baumgart on 01.07.20.
//

import KMPlaceholderTextView
import SnapKit
import UIKit
import SwiftKeychainWrapper

protocol PostCreateDelegate {
    func didSendPost(sentPost: SentPost)
}

class PostCreateViewController: UIViewController {
    //var sendButton: UIButton!
    var userPfp: UIImageView!
    var contentTextView: KMPlaceholderTextView!
    var type: PostType!
    var parentID: String?
	var imageButton: UIBarButtonItem!
	
	var selectedImage: UIImage?
	var imagePicker: UIImagePickerController!

    var delegate: PostCreateDelegate!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        hideKeyboardWhenTappedAround()
        navigationItem.title = type == PostType.post ? "Post" : "Reply"
        navigationController?.navigationBar.prefersLargeTitles = false
		
		imagePicker = UIImagePickerController()
		imagePicker.allowsEditing = false
		imagePicker.mediaTypes = ["public.image"]
		imagePicker.delegate = self
		
		imageButton = UIBarButtonItem(image: UIImage(systemName: "photo"), style: .plain, target: self, action: #selector(self.openImagePicker))
		
		let sendButton = UIBarButtonItem(image: UIImage(systemName: "paperplane.fill"), style: .plain, target: self, action: #selector(self.sendPost))
		
		navigationItem.leftBarButtonItem = imageButton
		navigationItem.rightBarButtonItem = sendButton

        /*sendButton = UIButton(type: .system)
        sendButton.setTitle(type == PostType.post ? "Post" : "Reply", for: .normal)
        sendButton.setTitleColor(.white, for: .normal)
        sendButton.backgroundColor = UIColor(named: "PostButtonColor")
        sendButton.layer.cornerRadius = 12
        sendButton.titleLabel?.font = .boldSystemFont(ofSize: 17)
        sendButton.addTarget(self, action: #selector(sendPost), for: .touchUpInside)
        view.addSubview(sendButton)*/
		
		/*imageButton = UIButton(type: .system)
		imageButton.setImage(UIImage(systemName: "photo"), for: .normal)
		imageButton.addTarget(self, action: #selector(self.openImagePicker), for: .touchUpInside)
		view.addSubview(imageButton)*/
		
		let userUsername = KeychainWrapper.standard.string(forKey: "dev.abmgrt.spica.user.username")

        let pfpImage = ImageLoader.default.loadImageFromInternet(url: URL(string: "https://avatar.alles.cx/u/\(userUsername!)")!)
        userPfp = UIImageView(frame: .zero)
        userPfp.image = pfpImage
        userPfp.layer.cornerRadius = 20
        userPfp.contentMode = .scaleAspectFit
        userPfp.clipsToBounds = true
        view.addSubview(userPfp)

        contentTextView = KMPlaceholderTextView(frame: .zero)
        contentTextView.font = .systemFont(ofSize: 18)
        contentTextView.placeholder = "What's on your mind?"
		contentTextView.placeholderColor = UIColor.tertiaryLabel

        view.addSubview(contentTextView)

        /*sendButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.snp.bottom).offset(-50)
            make.centerX.equalTo(view.snp.centerX)
            make.height.equalTo(50)
            make.width.equalTo(view.snp.width).offset(-32)
        }*/

        userPfp.snp.makeConstraints { make in
            make.height.equalTo(40)
            make.width.equalTo(40)
            make.top.equalTo(view.snp.top).offset(80)
            make.left.equalTo(view.snp.left).offset(16)
        }
		
		/*imageButton.snp.makeConstraints { (make) in
			make.height.equalTo(40)
			make.width.equalTo(40)
			make.bottom.equalTo(view.snp.bottom).offset(-80)
			make.left.equalTo(view.snp.left).offset(16)
		}*/

        contentTextView.snp.makeConstraints { make in
            make.top.equalTo(view.snp.top).offset(80)
            make.left.equalTo(view.snp.left).offset(72)
            make.right.equalTo(view.snp.right).offset(-32)
			make.bottom.equalTo(view.snp.bottom).offset(-16)
        }

        // Do any additional setup after loading the view.
    }
	
	@objc func openImagePicker(sender: UIBarButtonItem) {
		print(selectedImage)
		if selectedImage != nil {
			EZAlertController.actionSheet("Image", message: "Select an action", sourceView: view, actions: [
			UIAlertAction(title: "Select another image", style: .default, handler: { (_) in
				//self.imagePicker.present(from: self.view)
				self.present(self.imagePicker, animated: true, completion: nil)
			}),UIAlertAction(title: "Remove", style: .destructive, handler: { (_) in
				self.selectedImage = nil
				self.imageButton.image = UIImage(systemName: "photo")
			}), UIAlertAction(title: "Cancel", style: .cancel, handler: nil)])
		}
		else {
			present(imagePicker, animated: true, completion: nil)
		}
		
	}

    @objc func sendPost() {
        contentTextView.layer.cornerRadius = 0
        contentTextView.layer.borderWidth = 0
        contentTextView.layer.borderColor = UIColor.clear.cgColor
        if contentTextView.text.isEmpty {
            contentTextView.layer.cornerRadius = 12
            contentTextView.layer.borderWidth = 1
            contentTextView.layer.borderColor = UIColor.systemRed.cgColor
            return
        } else {
            AllesAPI.default.sendPost(newPost: NewPost(content: contentTextView.text, image: selectedImage, type: type, parent: parentID)) { result in
                switch result {
                case let .success(sentPost):

                    DispatchQueue.main.async {
                        self.delegate.didSendPost(sentPost: sentPost)
                        self.dismiss(animated: true, completion: nil)
                    }
                case let .failure(apiError):
                    DispatchQueue.main.async {
                        EZAlertController.alert("Error", message: apiError.message, buttons: ["Ok"]) { _, _ in
                            if apiError.action != nil, apiError.actionParameter != nil {
                                if apiError.action == AllesAPIErrorAction.navigate {
                                    if apiError.actionParameter == "login" {
                                        let mySceneDelegate = self.view.window!.windowScene!.delegate as! SceneDelegate
                                        mySceneDelegate.window?.rootViewController = UINavigationController(rootViewController: LoginViewController())
                                        mySceneDelegate.window?.makeKeyAndVisible()
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    /*
     // MARK: - Navigation

     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         // Get the new view controller using segue.destination.
         // Pass the selected object to the new view controller.
     }
     */
}

extension PostCreateViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
		   if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
			self.selectedImage = pickedImage
			imageButton.image = UIImage(systemName: "photo.fill")
		   }
		   
		   dismiss(animated: true, completion: nil)
	   }
	   
	   func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
		   dismiss(animated: true, completion: nil)
	   }
	
}

enum PostType {
    case post
    case reply
}
