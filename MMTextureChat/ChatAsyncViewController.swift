//
//  ChatAsyncViewController.swift
//  MMTextureChat
//
//  Created by Mukesh on 11/07/17.
//  Copyright © 2017 MadAboutApps. All rights reserved.
//

import UIKit
import AsyncDisplayKit
import MBPhotoPicker
import ionicons

open class ChatAsyncViewController: UIViewController , ChatDelegate {
    
    @IBOutlet weak var justTemporaryForTesting: UIView! {didSet {chatView = justTemporaryForTesting}}
    public var chatView: UIView! //Has to be passed in viewDidLoad!
    public var tintColor: UIColor! {
        didSet {
            kDefaultOutgoingColor = tintColor
        }
    }
    
    var collectionView : ASCollectionNode!
    var messages = [MMMessage]()
    let cellId = "cellId"
    var userIds = [[String : NSRange]]()
    var photo: MBPhotoPicker!
    var lastRange : NSRange!
    var senderId = "me"
    var showEarlierMessage = false
    var keyBoardTap : UITapGestureRecognizer!
    
    public var textView: UITextView!
    var constraint: NSLayoutConstraint?
    var isMenuHidden: Bool = false
    
//    override open func viewWillLayoutSubviews() {
//        self.collectionView.frame = CGRect(0,0,chatView.bounds.width , chatView.bounds.height );
//    }
    
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.showEarlierMessage = true
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        fetchMessages()
        
        let layout = ChatCollectionViewFlowLayout()
        layout.minimumLineSpacing  = 0
        layout.minimumInteritemSpacing = 0
        
        let collectionNode = ASCollectionNode(collectionViewLayout: layout)
        self.collectionView = collectionNode
        self.collectionView.backgroundColor = UIColor.clear
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        chatView.addSubnode(self.collectionView)
        
        
        
        //toolbar
        textView = UITextView(frame: .zero)
        textView.layer.borderColor = UIColor.lightGray.cgColor
        textView.layer.borderWidth = 0.4
        textView.layer.cornerRadius = 4
        textView.delegate = self
        textView.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)
        
        //frame set
        self.collectionView.frame = CGRect(0,0,chatView.bounds.width , chatView.bounds.height );
        
        collectionView.view.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 80, right: 0)
        collectionView.view.keyboardDismissMode = .interactive
        
        // Swift
        if #available(iOS 10, *) {
            collectionView.view.isPrefetchingEnabled = false
        }
        
        collectionView.transform = CATransform3DMakeRotation(CGFloat.pi, 0, 0, 1)
    }
    
    deinit {
        collectionView.dataSource = nil
        collectionView.delegate = nil
    }
    
    func openuserProfile(message: MMMessage) {
//        print("click click")
    }
    
    
    func openImageGallery(message: MMMessage) {
        if let _ = message.imageUrl{
            openGallery(message: message)
        } else if let _ = message.videoUrl{
            openGallery(message: message)
        }
    }
    
    func openGallery(message: MMMessage){
        let arr = messages.filter {
            ( $0.imageUrl != nil ||  $0.videoUrl != nil)
        }
        
        if let vc = UIApplication.shared.keyWindow?.visibleViewController{
            
            if let _ = messages.index(of: message) {
                
                let gallery = GalleryZoomViewController(collectionViewLayout: UICollectionViewLayout())
                gallery.sourceURLArr = arr
                gallery.modalTransitionStyle = .crossDissolve
                if let index = arr.index(of: message){
                    gallery.initialIndex = index
                    
                }
                
                vc.present(gallery, animated: true, completion: nil)
            }
            
            
        }
    }
    
    //MARK: - Fetch Messages
    func fetchMessages(){
        if(showEarlierMessage == true){
            
            var paths = [IndexPath]()
            let size = messages.count
            var temp = [MMMessage]()
            let mess = [MMMessage(msg: "Hello all"),MMMessage(msg: " all"),MMMessage(msg: "Hello all"),MMMessage(msg: "Hello all"),MMMessage(msg: " all"),MMMessage(msg: "Hello all"),MMMessage(msg: "Hello all"),MMMessage(msg: " all"),MMMessage(msg: " all"),MMMessage(msg: "Hello all"),MMMessage(msg: " all"),MMMessage(msg: "Hello all"),MMMessage(msg: "Hello all"),MMMessage(msg: " all"),MMMessage(msg: "Hello all"),MMMessage(msg: "Hello all"),MMMessage(msg: " all")]
            for i in 0 ..< mess.count{
                
                messages.append(mess[i])
                paths.append(IndexPath(item: size + i, section: 0))
            }
            
            self.collectionView.performBatchUpdates({
                self.collectionView.insertItems(at: paths)
                
            }, completion: { (bool) in
                
            })
            
        }else{
            messages.append(MMMessage(msg: "Hello all"))
            messages.append(MMMessage(msg: "This is quick demo"))
            messages.append(MMMessage(msg: "Texture’s basic unit is the node. ASDisplayNode is an abstraction over UIView, which in turn is an abstraction over CALayer. Unlike views, which can only be used on the main thread, nodes are thread-safe: you can instantiate and configure entire hierarchies of them in parallel on background threads."))
            messages.append(MMMessage(image: "https://s-media-cache-ak0.pinimg.com/736x/43/bd/ef/43bdef2a0af4f55238f1df4913b3188b--super-hero-shirts-ironman.jpg"))
            messages.last!.sectionStamp = "stampo"
            messages.append(MMMessage(msg: "Texture lets you move image decoding, text sizing and rendering, and other expensive UI operations off the main thread, to keep the main thread available to respond to user interaction. Texture has other tricks up its sleeve too… but we’ll get to that later"))
            messages.append(MMMessage(image: "https://media3.giphy.com/media/kEKcOWl8RMLde/giphy.gif", caption: "demo caption"))
            messages.append(MMMessage(msg: "Understanding of performance issue, especially some common uses like tableview pre rendering, helps"))
            messages.append(MMMessage(videourl: "https://www.w3schools.com/html/mov_bbb.mp4"))
            
            
        }
        
        
    }
    
    
    
    // MARK: - Keyboard
    @objc final func keyboardWillShow(notification: Notification) {
        moveToolbar(up: true, notification: notification)
    }
    
    @objc final func keyboardWillHide(notification: Notification) {
        moveToolbar(up: false, notification: notification)
    }
    
    final func moveToolbar(up: Bool, notification: Notification) {
        guard let userInfo = notification.userInfo else {
            return
        }
        let animationDuration: TimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        let keyboardHeight = up ? (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.height : 0
        
        // Animation
//        self.toolbarBottomConstraint?.constant = -keyboardHeight
//        self.inputToolbar.setNeedsUpdateConstraints()
        
        
        collectionView.view.contentInset = UIEdgeInsets(top: keyboardHeight + 0, left: 0, bottom: 10, right: 0)
        collectionView.view.scrollIndicatorInsets = UIEdgeInsets(top: keyboardHeight + 0, left: 0, bottom: 10, right: collectionView.bounds.size.width - 8)
        
        if up {
            collectionView.view.scrollToItem(at: IndexPath(item: 0, section: 0), at: .top, animated: true)
        }
        
        UIView.animate(withDuration: animationDuration, animations: {
            self.view.layoutIfNeeded()
        })
        
        self.isMenuHidden = up
        keyBoardTap.isEnabled = up
        
    }
    
    //MARK:-  User Tag logic
    func removeAtr(textView : UITextView , range : NSRange , bool : Bool){
        
        
        let attr = NSMutableAttributedString(attributedString: textView.attributedText)
        attr.removeAttribute(NSAttributedStringKey.link, range: range)
        if(bool){
            attr.replaceCharacters(in: range, with: "")
        }
        textView.attributedText = attr
        
    }
    
    
    
    func checkRange(){
        if let attr = textView.attributedText{
            var i = 0
            attr.enumerateAttributes( in: NSMakeRange(0, attr.length), options: NSAttributedString.EnumerationOptions.longestEffectiveRangeNotRequired, using: { (dict, range, bool) in
                
                for (key , _) in dict{
                    if(key == NSAttributedStringKey.link){
                        
                        var user = userIds[i]
                        
                        for (userkey,_) in user{
                            user.updateValue(range, forKey: userkey)
                            userIds[i] = user
                            
                        }
                        
                        i = i + 1
                    }
                }
            })
        }
    }
    
    func formatTextInTextView(textView: UITextView) {
        
        
        textView.linkTextAttributes = [NSAttributedStringKey.foregroundColor.rawValue : UIColor.blue , NSAttributedStringKey.underlineStyle.rawValue : NSUnderlineStyle.styleNone.rawValue]
        textView.attributedText = NSAttributedString(string: textView.text, attributes: [NSAttributedStringKey.font : UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)])
        
        let attr = NSMutableAttributedString(attributedString: textView.attributedText)
        
        for user in userIds{
            for (key,value) in user{
                attr.addAttribute(NSAttributedStringKey.link, value: key, range: value)
                
            }
        }
        
        textView.attributedText = attr
        
    }
    
    
    //MARK: - Load Earlier
    func loadMoreMessages(){
        fetchMessages()
    }
    
    
    //MARK: - Camera
    @objc func didPressAccessoryButton() {
        
        photo = MBPhotoPicker()
        photo?.disableEntitlements = true
        
        photo?.onPhoto = { (_ image: UIImage?) -> Void in
//            print("Selected image")
            if let img = image{
                
                self.confirmImagePost(img: img )
                self.photo = nil
            }
            
        }
        photo?.onCancel = {
            self.photo = nil
//            print("Cancel Pressed")
        }
        photo?.onError = { (_ error: MBPhotoPicker.ErrorPhotoPicker?) -> Void in
//            print("Error: \(String(describing: error?.rawValue))")
            self.photo = nil
        }
        photo?.present(self)
        
    }
    
    
    func confirmImagePost(img : UIImage){
//        print("write your code for image")
        
    }
    
    //MARK: - Send
    @objc func sendPressed(){
        if let textView = self.textView {
            
            let attr = NSMutableAttributedString(attributedString: textView.attributedText)
            if(attr.string.characters.count != 0){
                let message = MMMessage(msg: attr.string)
                message.isOutgoing = true
                messages.insert(message, at: 0)
                self.collectionView.insertItems(at: [IndexPath(item: 0, section: 0)])
                
                //Reset
                self.textView?.text = nil
                if let constraint: NSLayoutConstraint = self.constraint {
                    self.textView?.removeConstraint(constraint)
                }
            }
        }
    }
    
    
    //From
    func getNSRange(textView : UITextView) -> NSRange! {
        guard let range = textView.selectedTextRange else { return nil }
        let location = textView.offset(from: textView.beginningOfDocument, to: range.start)
        let length = textView.offset(from: range.start, to: range.end)
        return NSRange(location: location, length: length)
        
    }
    
    
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if(scrollView.isAtBottom && (showEarlierMessage ) ){
            loadMoreMessages()
        }
    }
    
    
}

extension ChatAsyncViewController: UITextViewDelegate {
    open func textViewDidChange(_ textView: UITextView) {
        
        
        let size: CGSize = textView.sizeThatFits(textView.bounds.size)
        if let constraint: NSLayoutConstraint = self.constraint {
            textView.removeConstraint(constraint)
        }
        self.constraint = textView.heightAnchor.constraint(equalToConstant: size.height)
        self.constraint?.priority = UILayoutPriority.defaultHigh
        self.constraint?.isActive = true
        
        checkRange()
        //            formatTextInTextView(textView: textView)
        
    }
    
    open func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(textView != self.textView){
            return false
        }
        
        var i = 0
        
        for usr in userIds{
            for (_ , value) in usr{
                if(NSLocationInRange(range.location, value)){
                    userIds.remove(at: i)
                    let remove = text == "" && range.length == 1
                    removeAtr(textView: textView, range: value , bool: remove)
                }
            }
            i = i + 1
        }
        
        return true
    }
    
    open func textViewDidBeginEditing(_ textView: UITextView) {
        self.isMenuHidden = true
    }
}

extension ChatAsyncViewController : ASCollectionDelegate{
    
    open func shouldBatchFetch(for collectionView: ASCollectionView) -> Bool {
        return true
    }
    
    open func collectionView(_ collectionView: ASCollectionView, constrainedSizeForNodeAt indexPath: IndexPath) -> ASSizeRange {
        return ASSizeRangeMake(CGSize(width: UIScreen.main.bounds.size.width, height: 0), CGSize(width: UIScreen.main.bounds.size.width, height: CGFloat.greatestFiniteMagnitude))
        
    }
    
}
extension ChatAsyncViewController : ASCollectionDataSource{
    open func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    open func collectionView(_ collectionView: ASCollectionView, nodeBlockForItemAt indexPath: IndexPath) -> ASCellNodeBlock {
        let msg = messages[indexPath.item]
        
        return {
            let node = ChatAsyncCell(message: msg , isOutGoing: msg.isOutgoing)
            node.delegate = self
            node.transform = CATransform3DMakeRotation(CGFloat.pi, 0, 0, 1)
            return node
        }
    }
}





