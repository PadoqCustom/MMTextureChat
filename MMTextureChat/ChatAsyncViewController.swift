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
import DropDown
import Toolbar
import ionicons

class ChatAsyncViewController: UIViewController , ChatDelegate {
    
    var collectionView : ASCollectionNode!
    var messages = [Message]()
    let cellId = "cellId"
    var userIds = [[String : NSRange]]()
    var photo: MBPhotoPicker!
    var jidStrArr = NSMutableArray(array: ["Mukesh","Mandy","Jack","Jill","User"])
    var lastRange : NSRange!
    var dropDown : DropDown!
    var lastWord = ""
    var senderId = "me"
    var showEarlierMessage = false
    var keyBoardTap : UITapGestureRecognizer!
    

    
    //Toolbar
    var toolbarBottomConstraint: NSLayoutConstraint?
    let inputToolbar: Toolbar = Toolbar()
    
    lazy var picture: ToolbarItem = {
        let item: ToolbarItem = ToolbarItem(image: IonIcons.image(withIcon:"\u{f118}", size: 25, color: UIColor.lightGray), target: self, action: #selector(didPressAccessoryButton))
        item.tintColor = UIColor.blue
        return item
    }()
    
    
    lazy var sendBut: ToolbarItem = {
        let item: ToolbarItem = ToolbarItem(image: IonIcons.image(withIcon:"\u{f2f6}", size: 25, color: UIColor.lightGray), target: self, action: #selector(sendPressed))
        item.tintColor = UIColor.blue
        
        return item
    }()
    var textView: UITextView!
    var constraint: NSLayoutConstraint?
    var isMenuHidden: Bool = false
        

    
    override func loadView() {
        super.loadView()
        self.view.addSubview(inputToolbar)
        self.toolbarBottomConstraint = self.inputToolbar.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0)
        self.toolbarBottomConstraint?.isActive = true
        
    }
    
    func endEdit(){
        self.view.endEditing(true)
    }
    
    
    override func viewWillLayoutSubviews() {
        self.collectionView.frame = CGRect(0,0,view.bounds.width , view.bounds.height );

    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        let indexPath = IndexPath(item: 0, section: 0)
//        self.collectionView.scrollToItem(at: indexPath, at: .top, animated: false)
        self.showEarlierMessage = true
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        fetchMessages()
        
        let layout = ChatCollectionViewFlowLayout()
        layout.minimumLineSpacing  = 0
        layout.minimumInteritemSpacing = 0
        
        let collectionNode = ASCollectionNode(collectionViewLayout: layout)
        self.collectionView = collectionNode
        self.collectionView.backgroundColor = UIColor.white
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        view.addSubnode(self.collectionView)
        

        
        //toolbar
        textView = UITextView(frame: .zero)
        textView.layer.borderColor = UIColor.lightGray.cgColor
        textView.layer.borderWidth = 0.4
        textView.layer.cornerRadius = 4
        textView.delegate = self
        textView.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)
        
        
        self.inputToolbar.setItems([self.picture, ToolbarItem(customView: self.textView) , self.sendBut], animated: false)
        self.inputToolbar.maximumHeight = 200
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        keyBoardTap = UITapGestureRecognizer(target: self, action:  #selector(endEdit))
        self.view.addGestureRecognizer(keyBoardTap)
        keyBoardTap.isEnabled = false
        setDropDown()
        
        
        //frame set
        self.collectionView.frame = CGRect(0,0,view.bounds.width , view.bounds.height );
        self.view.bringSubview(toFront: inputToolbar)
        
        collectionView.view.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 80, right: 0)
        collectionView.view.keyboardDismissMode = .onDrag
        
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
    

    //MARK: - Chat delegates
    
    func openuserProfile(message: Message) {
            print("click click")
    }
    
    
    func openImageGallery(message: Message) {
        if let _ = message.imageUrl{
            openGallery(message: message)
        } else if let _ = message.videoUrl{
            openGallery(message: message)
        }
    }
    
    func openGallery(message: Message){
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
//                let board = UIStoryboard(name: "Main", bundle: nil)
//                if let gallery = board.instantiateViewController(withIdentifier: "galleryzoom") as? GalleryZoomViewController{
//
//                }
                
                
            }
            
            
        }
    }
    
    //MARK: - Fetch Messages
    func fetchMessages(){
        if(showEarlierMessage == true){
            
            var paths = [IndexPath]()
            let size = messages.count
            var temp = [Message]()
            let mess = [Message(msg: "Hello all"),Message(msg: " all"),Message(msg: "Hello all"),Message(msg: "Hello all"),Message(msg: " all"),Message(msg: "Hello all"),Message(msg: "Hello all"),Message(msg: " all"),Message(msg: " all"),Message(msg: "Hello all"),Message(msg: " all"),Message(msg: "Hello all"),Message(msg: "Hello all"),Message(msg: " all"),Message(msg: "Hello all"),Message(msg: "Hello all"),Message(msg: " all")]
            for i in 0 ..< mess.count{
                
                messages.append(mess[i])
                paths.append(IndexPath(item: size + i, section: 0))
            }
            
            self.collectionView.performBatchUpdates({
                self.collectionView.insertItems(at: paths)
                
            }, completion: { (bool) in

            })

        }else{
            messages.append(Message(msg: "Hello all"))
            messages.append(Message(msg: "This is quick demo"))
            messages.append(Message(msg: "Texture’s basic unit is the node. ASDisplayNode is an abstraction over UIView, which in turn is an abstraction over CALayer. Unlike views, which can only be used on the main thread, nodes are thread-safe: you can instantiate and configure entire hierarchies of them in parallel on background threads."))
            messages.append(Message(image: "https://s-media-cache-ak0.pinimg.com/736x/43/bd/ef/43bdef2a0af4f55238f1df4913b3188b--super-hero-shirts-ironman.jpg"))
            messages.append(Message(msg: "Texture lets you move image decoding, text sizing and rendering, and other expensive UI operations off the main thread, to keep the main thread available to respond to user interaction. Texture has other tricks up its sleeve too… but we’ll get to that later"))
            messages.append(Message(image: "https://media3.giphy.com/media/kEKcOWl8RMLde/giphy.gif", caption: "demo caption"))
            messages.append(Message(msg: "Understanding of performance issue, especially some common uses like tableview pre rendering, helps"))
            messages.append(Message(videourl: "https://www.w3schools.com/html/mov_bbb.mp4"))
            

        }


    }
    
    
    
    // MARK: - Keyboard
    final func keyboardWillShow(notification: Notification) {
        moveToolbar(up: true, notification: notification)
    }
    
    final func keyboardWillHide(notification: Notification) {
        moveToolbar(up: false, notification: notification)
    }
    
    final func moveToolbar(up: Bool, notification: Notification) {
        guard let userInfo = notification.userInfo else {
            return
        }
        let animationDuration: TimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        let keyboardHeight = up ? (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.height : 0
        
        // Animation
        self.toolbarBottomConstraint?.constant = -keyboardHeight
        self.inputToolbar.setNeedsUpdateConstraints()
        
        
        collectionView.view.contentInset = UIEdgeInsets(top: keyboardHeight + inputToolbar.frame.height, left: 0, bottom: 10, right: 0)
        collectionView.view.scrollIndicatorInsets = UIEdgeInsets(top: keyboardHeight + inputToolbar.frame.height, left: 0, bottom: 10, right: collectionView.bounds.size.width - 8)
        
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
        attr.removeAttribute(NSLinkAttributeName, range: range)
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
                    if(key == NSLinkAttributeName){
                        
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
        
        
        textView.linkTextAttributes = [NSForegroundColorAttributeName : UIColor.blue , NSUnderlineStyleAttributeName : NSUnderlineStyle.styleNone.rawValue]
        textView.attributedText = NSAttributedString(string: textView.text, attributes: [NSFontAttributeName : UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)])
        
        let attr = NSMutableAttributedString(attributedString: textView.attributedText)
        
        for user in userIds{
            for (key,value) in user{
                attr.addAttribute(NSLinkAttributeName, value: key, range: value)
                
            }
        }
        
        textView.attributedText = attr

    }
    
    
    
    func textChanged(textView: UITextView){
        lastRange = getNSRange(textView: textView)
        let selectedRange = textView.selectedRange
        let beginning = textView.beginningOfDocument
        if let start = textView.position(from: beginning, offset:  selectedRange.location){
            if let end = textView.position(from : start, offset: selectedRange.length){
                
                if let textRange = textView.tokenizer.rangeEnclosingPosition(end, with: UITextGranularity.word, inDirection: UITextLayoutDirection.left.rawValue){
                    if let wordTyped = textView.text(in: textRange){
                        print(wordTyped)
                        
                        let wordsInSentence = textView.text.components(separatedBy:" ")
                        for word in  wordsInSentence{
                            let range = (textView.text as NSString).range(of:word)
                            
                            
                            if(selectedRange.location >= range.location  && selectedRange.location <= (range.location + range.length)){
                                
                                if(word.hasPrefix("@")){
                                    if(dropDown.isHidden){
                                        dropDown.show()
                                    }
                                    
                                    lastWord = word.replacingOccurrences(of:"@", with: "")
                                    reloadDataSource(str: lastWord)
                                    
                                }else{
                                    dropDown.hide()
                                    lastWord = ""
                                    
                                }
                            }else{
                                
                            }
                            
                        }
                        
                        
                    }
                }
                
            }
        }
        
        
        
    }
    
    
    
    //MARK: - Dropdown
    func reloadDataSource(str : String){
        
        let predicate = NSPredicate(format: "SELF CONTAINS[cd] %@", argumentArray: [str ])
        
        let temp = NSMutableArray(array: jidStrArr.filtered(using: predicate))
        if(temp.count == 0){
            dropDown.dataSource =  jidStrArr as! [String]
            
        }else{
            dropDown.dataSource =  temp as! [String]
        }
        
    }
    
    func setDropDown(){
        
        dropDown = DropDown()
        
        // The view to which the drop down will appear on
        dropDown.anchorView = inputToolbar // UIView or UIBarButtonItem
        dropDown.direction = .top
        dropDown.backgroundColor = UIColor.white
        // The list of items to display. Can be changed dynamically
        
        dropDown.dataSource = jidStrArr as! [String]
        
        
        dropDown.cellHeight = 60
        dropDown.topOffset = CGPoint(x: 0, y: -50)
        
        /*** IMPORTANT PART FOR CUSTOM CELLS ***/
//        dropDown.cellNib = UINib(nibName: "DropDownTableViewCell", bundle: nil)
        
 
        
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            print("Selected item: \(item) at index: \(index)")
            if let textView = self.textView{
                
                if let jid = self.jidStrArr[index] as? String{
                    
                    let tempRange = NSMakeRange(self.lastRange.location - self.lastWord.characters.count, self.lastWord.characters.count)
                    if(tempRange.location == 0){
                        self.dropDown.hide()
                        return
                    }
                    let newcontent = (textView.text as NSString).replacingCharacters(in: NSMakeRange(self.lastRange.location - self.lastWord.characters.count, self.lastWord.characters.count), with: item + " ")
                    textView.text = newcontent
                    
                    
                    self.userIds.append([jid : NSMakeRange(tempRange.location - 1, item.characters.count + 1)])
                    

                    
                    self.formatTextInTextView(textView: textView)
                    
                    
                }
                
            }

            
        }
        
        /*** END - IMPORTANT PART FOR CUSTOM CELLS ***/
    }
    
    
    //MARK: - Load Earlier
    func loadMoreMessages(){
        fetchMessages()
    }
    
    
    //MARK: - Camera
    func didPressAccessoryButton() {
        
        photo = MBPhotoPicker()
        photo?.disableEntitlements = true
        
        photo?.onPhoto = { (_ image: UIImage?) -> Void in
            print("Selected image")
            if let img = image{
                
                self.confirmImagePost(img: img )
                self.photo = nil
            }
            
        }
        photo?.onCancel = {
            self.photo = nil
            print("Cancel Pressed")
        }
        photo?.onError = { (_ error: MBPhotoPicker.ErrorPhotoPicker?) -> Void in
            print("Error: \(String(describing: error?.rawValue))")
            self.photo = nil
        }
        photo?.present(self)
        
    }
    
    
    func confirmImagePost(img : UIImage){
        print("write your code for image")
        
    }
    
    //MARK: - Send
    func sendPressed(){
        if let textView = self.textView {
            
            let attr = NSMutableAttributedString(attributedString: textView.attributedText)
            if(attr.string.characters.count != 0){
                let message = Message(msg: attr.string)
                message.fromId = senderId
                messages.insert(message, at: 0)
                self.collectionView.insertItems(at: [IndexPath(item: 0, section: 0)])
                
                //Reset
                self.textView?.text = nil
                if let constraint: NSLayoutConstraint = self.constraint {
                    self.textView?.removeConstraint(constraint)
                }
                self.inputToolbar.setNeedsLayout()
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
    
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if(scrollView.isAtBottom && (showEarlierMessage ) ){
            loadMoreMessages()
        }
    }
    
    
}

extension ChatAsyncViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        
        if(textView == self.textView){
            let size: CGSize = textView.sizeThatFits(textView.bounds.size)
            if let constraint: NSLayoutConstraint = self.constraint {
                textView.removeConstraint(constraint)
            }
            self.constraint = textView.heightAnchor.constraint(equalToConstant: size.height)
            self.constraint?.priority = UILayoutPriorityDefaultHigh
            self.constraint?.isActive = true
            
            
            textChanged(textView: textView)
            checkRange()
            //            formatTextInTextView(textView: textView)
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
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
        if(text == "@"){
            dropDown.show()
            reloadDataSource(str: "")
            
        }else if(dropDown.dataSource.count > 0){
            if(text == "\n" ){
                dropDown.hide()
                lastWord = ""
            }
        }
        else{
            dropDown.hide()
            lastWord = ""
            dropDown.dataSource =  jidStrArr as! [String]
            
        }
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        self.isMenuHidden = true
    }
}

extension ChatAsyncViewController : ASCollectionDelegate{
    
    func shouldBatchFetch(for collectionView: ASCollectionView) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: ASCollectionView, constrainedSizeForNodeAt indexPath: IndexPath) -> ASSizeRange {
        return ASSizeRangeMake(CGSize(width: UIScreen.main.bounds.size.width, height: 0), CGSize(width: UIScreen.main.bounds.size.width, height: CGFloat.greatestFiniteMagnitude))
        
    }
    
}
extension ChatAsyncViewController : ASCollectionDataSource{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    func collectionView(_ collectionView: ASCollectionView, nodeBlockForItemAt indexPath: IndexPath) -> ASCellNodeBlock {
        let msg = messages[indexPath.item]
        let isOut = msg.fromId == senderId ? true : false
        
        return {
            let node = ChatAsyncCell(message: msg , isOutGoing: isOut)
            node.delegate = self
            node.transform = CATransform3DMakeRotation(CGFloat.pi, 0, 0, 1)
            return node
        }
    }
}





