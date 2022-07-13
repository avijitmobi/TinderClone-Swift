//
//  ExtraFunctionality.swift
//  Velix.ID
//
//  Created by Kazma Technology on 05/07/18.
//  Copyright © 2018 Kazma Technology. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import AVKit
import SafariServices
import SDWebImage

enum ValidationExpression : String {
    case email = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
}

extension UIImageView{
    
    func setImageFrom(url : URL?){
        self.contentMode = .scaleAspectFill
        self.clipsToBounds = true
        self.sd_setShowActivityIndicatorView(true)
        self.sd_setImage(with: url, placeholderImage: nil) { (image, error, cache, urls) in
            if (error != nil) {
                self.image = UIImage(named: "logo_red_circle")
            } else {
                self.image = image
            }
        }
    }
    
    func getImage(withUrl : String, placeHolder : UIImage?,imgContentMode : UIView.ContentMode = .scaleAspectFill,imgContentModeOfPlaceHolder : UIView.ContentMode = .scaleAspectFill){
        if #available(iOS 13.0, *) {
            self.sd_setIndicatorStyle(.medium)
        } else {
            self.sd_setIndicatorStyle(.gray)
        }
        self.sd_setShowActivityIndicatorView(true)
        self.sd_setImage(with: URL(string: (withUrl).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? withUrl), placeholderImage: nil) { (image, error, cache, urls) in
            DispatchQueue.main.async {
                if (error != nil) {
                    self.contentMode = imgContentModeOfPlaceHolder
                    self.image = placeHolder
                    self.backgroundColor = UIColor(red: 224/255, green: 224/255, blue: 224/255, alpha: 1)
                } else {
                    self.image = image
                    self.backgroundColor = .black
                    self.contentMode = imgContentMode
                }
            }
        }
    }
}


extension String {
    
    func getDate(with format : String) -> Date{
        let df = DateFormatter()
        df.dateFormat = format
        return df.date(from: self) ?? Date()
    }
    
    func twoDecimalDigit() -> String {
        let myDouble = NSString(string: self).doubleValue
        let doubleStr = String(format: "%.2f", ceil(myDouble*100)/100)
        return doubleStr
    }
    
    func threeDecimalDigit() -> String {
        let myDouble = NSString(string: self).doubleValue
        let doubleStr = String(format: "%.3f", ceil(myDouble*100)/100)
        return doubleStr
    }
    
    var hasOnlyNumericValue: Bool {
        guard self.count > 0 else { return false }
        let nums: Set<Character> = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
        return Set(self).isSubset(of: nums)
    }
    
    func inserting(_ c: String, every index: Int) -> String {
        return self.split(by: index).joined(separator: c)
    }
    
    func split(by length: Int) -> [String] {
        var startIndex = self.startIndex
        var results = [Substring]()
        while startIndex < self.endIndex {
            let endIndex = self.index(startIndex, offsetBy: length, limitedBy: self.endIndex) ?? self.endIndex
            results.append(self[startIndex..<endIndex])
            startIndex = endIndex
        }
        return results.map { String($0) }
    }
    
    
    func isValidPhone()-> Bool {
        let phoneNumberRegex = "^[6-9]\\d{9}$"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", phoneNumberRegex)
        let isValidPhone = phoneTest.evaluate(with: self)
        return isValidPhone
    }
    
    func isValidUsername() -> Bool {
        return self.range(of: "\\A\\w{3,15}\\z", options: .regularExpression) != nil
    }
    
    func isValidEmail() -> Bool {
        let regex = try! NSRegularExpression(pattern: "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$", options: .caseInsensitive)
        return regex.firstMatch(in: self, options: [], range: NSRange(location: 0, length: count)) != nil
    }
    
    func convertTo24Hours() -> String?{
        let dateAsString = self
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        let date = dateFormatter.date(from: dateAsString)
        dateFormatter.dateFormat = "HH:mm"
        if let date = date{
            let date24 = dateFormatter.string(from: date)
            return date24
        }else{
            return nil
        }
    }
    
    func convertTo12Hours() -> String?{
        let dateAsString = self
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        let date = dateFormatter.date(from: dateAsString)
        dateFormatter.dateFormat = "h:mm a"
        if let date = date{
            let date12 = dateFormatter.string(from: date)
            return date12
        }else{
            return nil
        }
    }
    
    func convertTo12HoursFromHHMMSS() -> String?{
        let dateAsString = self
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm:ss"
        let date = dateFormatter.date(from: dateAsString)
        dateFormatter.dateFormat = "h:mm a"
        if let date = date{
            let date12 = dateFormatter.string(from: date)
            return date12
        }else{
            return nil
        }
    }
    
}


extension UIImageView
{
    func roundCornersForAspectFit(radius : CGFloat)
    {
        self.layer.borderWidth = 1.0
        self.layer.masksToBounds = false
        self.layer.borderColor = UIColor.white.cgColor
        self.layer.cornerRadius = radius
        self.clipsToBounds = true
    }
}


extension Double{
    func toStringWithTwoPoint()->String{
        return NSString(format: "%.2f", self) as String
    }
    
    func toStringWithOnePoint()->String{
        return NSString(format: "%.1f", self) as String
    }
}

extension UIViewController {
    
    func getThumbnailImage(forUrl url: URL) -> UIImage? {
        let asset: AVAsset = AVAsset(url: url)
        let imageGenerator = AVAssetImageGenerator(asset: asset)

        do {
            let thumbnailImage = try imageGenerator.copyCGImage(at: CMTimeMake(value: 1, timescale: 60) , actualTime: nil)
            return UIImage(cgImage: thumbnailImage)
        } catch let error {
            print(error)
        }

        return nil
    }
    
    func playVideo(with url: URL?){
        guard let videoURL = url else {return}
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            let player = AVPlayer(url: videoURL)
            let playerViewController = AVPlayerViewController()
            playerViewController.player = player
            self.present(playerViewController, animated: true) {
                playerViewController.player?.play()
            }
        }
    }
    
    func openInstagram(with : String){
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            let appURL = URL(string: "instagram://user?username=\(with)")!
            let application = UIApplication.shared
            if application.canOpenURL(appURL) {
                application.open(appURL)
            } else {
                let webURL = URL(string: "https://instagram.com/\(with)")!
                application.open(webURL)
            }
        }
    }
    
    func generateQRCode(from string: String) -> UIImage? {
        let data = string.data(using: String.Encoding.ascii)
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 15, y: 15)
            if let output = filter.outputImage?.transformed(by: transform) {
                let context:CIContext = CIContext.init(options: nil)
                let cgImage:CGImage = context.createCGImage(output, from: output.extent)!
                let image:UIImage = UIImage.init(cgImage: cgImage)
                return image
            }
        }
        return nil
    }
    
    func openSafariView(withUrl : String,withColor : UIColor){
        if let url = URL(string: withUrl){
            let svc = SFSafariViewController(url: url)
            svc.dismissButtonStyle = .close
            svc.preferredBarTintColor = withColor
            svc.preferredControlTintColor = .white
            DispatchQueue.main.async {
                self.presentModalyViewController(from: self, present: svc, completion: nil)
            }
        }
    }
    
    func alertDialogWithImage(msg : String,btnTitle : String, Icon : UIImage,closure: (()->())? = nil) {
        let alrt = UIAlertController(title: "\n\n", message: "", preferredStyle: .alert)
        let cancel = UIAlertAction(title: btnTitle, style: .cancel) { (action) in
            closure?()
        }
        alrt.view.tintColor = UIColor.black
        alrt.addAction(cancel)
        let imageView = UIImageView(frame: CGRect(x: ((250/2)-23), y: 15, width: 55, height: 55))
        alrt.view.addSubview(imageView)
        alrt.view.clipsToBounds = true
        imageView.image = Icon
        alrt.message = msg
        DispatchQueue.main.async {
            self.present(alrt, animated: true, completion: nil)
        }
    }
    
    func alertWithInputTextFieldWithAnimate(title:String? = nil,subtitle:String? = nil,actionTitle:String? = "Add".localizedWithLanguage,cancelTitle:String? = "Cancel".localizedWithLanguage,inputPlaceholder:String? = nil,wrongInputPlaceholder : String? = "Wrong Entry".localizedWithLanguage,inputKeyboardType:UIKeyboardType,validation : ValidationExpression,actionHandler: ((_ text: String?) -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: subtitle, preferredStyle: .alert)
        let saveBtn = UIAlertAction(title: actionTitle, style: .default, handler: { (action:UIAlertAction) in
            if let txtField = alert.textFields?.first {
                guard let txt = txtField.text, txt != "", NSPredicate(format:"SELF MATCHES %@", validation.rawValue).evaluate(with: txt) else{
                    txtField.text = ""
                    txtField.placeholder = wrongInputPlaceholder
                    self.present(alert, animated: true, completion: {
                        let animation = CABasicAnimation(keyPath: "position")
                        animation.duration = 0.09
                        animation.repeatCount = 4
                        animation.autoreverses = true
                        animation.fromValue = NSValue(cgPoint: CGPoint(x: txtField.center.x - 8, y: txtField.center.y))
                        animation.toValue = NSValue(cgPoint: CGPoint(x: txtField.center.x + 8, y: txtField.center.y))
                        alert.textFields?.first?.layer.add(animation, forKey: "position")
                    })
                    return
                }
                actionHandler?(txt)
            }else{
                actionHandler?(nil)
            }
        })
        alert.addAction(saveBtn)
        alert.addTextField(configurationHandler: { (textField) in
            textField.placeholder = inputPlaceholder
            textField.keyboardType = inputKeyboardType
        })
        alert.addAction(UIAlertAction(title: cancelTitle, style: .cancel))
        self.present(alert, animated: true, completion: nil)
    }
}

extension UIView {
    
    class func fromNib<T: UIView>() -> T? {
        return Bundle(for: T.self).loadNibNamed(String(describing: T.self), owner: nil, options: nil)?.first as? T
    }
    
    fileprivate struct AssociatedObjectKeys {
        static var tapGestureRecognizer = "MediaViewerAssociatedObjectKey_mediaViewer"
    }
    
    fileprivate typealias Action = (() -> Void)?
    
    
    fileprivate var tapGestureRecognizerAction: Action? {
        set {
            if let newValue = newValue {
                // Computed properties get stored as associated objects
                objc_setAssociatedObject(self, &AssociatedObjectKeys.tapGestureRecognizer, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
            }
        }
        get {
            let tapGestureRecognizerActionInstance = objc_getAssociatedObject(self, &AssociatedObjectKeys.tapGestureRecognizer) as? Action
            return tapGestureRecognizerActionInstance
        }
    }
    
    
    public func addTapGestureRecognizer(action: (() -> Void)?) {
        self.isUserInteractionEnabled = true
        self.tapGestureRecognizerAction = action
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture))
        self.addGestureRecognizer(tapGestureRecognizer)
    }
    
    
    @objc fileprivate func handleTapGesture(sender: UITapGestureRecognizer) {
        if let action = self.tapGestureRecognizerAction {
            action?()
        } else {
            print("no action")
        }
    }
    
    class func fromNib<T: UIView>() -> T {
        
        return Bundle.main.loadNibNamed(String(describing: T.self), owner: nil, options: nil)![0] as! T
    }
}

extension Collection {
    func isExistIndex(at index: Index) -> Bool {
        return self.indices.contains(index) ? true : false
    }
}

extension UICollectionView {
    
    func getCellFrom(sender : UIView,completion : @escaping (UICollectionViewCell,IndexPath)->()){
        var superview = sender.superview
        while let view = superview, !(view is UICollectionViewCell) {
            superview = view.superview
        }
        guard let cell = superview as? UICollectionViewCell else {
            return
        }
        guard let indexPath = self.indexPath(for: cell) else {
            return
        }
        completion(cell,indexPath)
    }
    
    
    func reloadData(_ completion: @escaping () -> Void) {
        reloadData()
        DispatchQueue.main.async { completion() }
    }
}

extension Array where Array.Element: AnyObject {
    
    func index(ofElement element: Element) -> Int? {
        for (currentIndex, currentElement) in self.enumerated() {
            if currentElement === element {
                return currentIndex
            }
        }
        return nil
    }
}

extension Date {
    
    func getAge() -> Int?{
        return Calendar.current.dateComponents([.year], from: self, to: Date()).year
    }
    
    func getTimeAgoElapsedIntervalWithDate() -> String {
        let interval = Calendar.current.dateComponents([.year, .month, .day, .minute, .hour], from: self, to: Date())
        if let month = interval.month, month > 0 {
            if month > 1{
                let format = DateFormatter()
                format.dateFormat = "yyyy-MM-dd HH:mm:ss"
                format.locale = Locale(identifier: "en_US_POSIX")
                let common = UIViewController()
                let dateShare = common.getFormattedDate(strDate: format.string(from: self), inputFormat: "yyyy-MM-dd HH:MM:ss", outputFormat: "dd MMM, yyyy")
                let timeShare = common.getFormattedDate(strDate: format.string(from: self), inputFormat: "yyyy-MM-dd HH:MM:ss", outputFormat: "h:mm a")
                return "on \(dateShare) | \(timeShare)"
            }else{
                return month == 1 ? "\(month)" + " " + "month ago" :
                    "\(month)" + " " + "months ago"
            }
        } else if let day = interval.day, day > 0 {
            return day == 1 ? "\(day)" + " " + "day ago" :
                "\(day)" + " " + "days ago"
        }else if let hour = interval.hour, hour > 0{
            return hour == 1 ? "\(hour)" + " " + "hour ago" :
                "\(hour)" + " " + "hours ago"
        }else if let min = interval.minute, min > 0{
            return min == 1 ? "\(min)" + " " + "min ago" :
                "\(min)" + " " + "minutes ago"
        }else{
            return "just now"
        }
        
    }
    
    
    func getTimeAgoElapsedInterval() -> String {
        let interval = Calendar.current.dateComponents([.year, .month, .day, .minute, .hour], from: self, to: Date())
        if let year = interval.year, year > 0 {
            return year == 1 ? "\(year)" + " " + "year ago" :
                "\(year)" + " " + "years ago"
        } else if let month = interval.month, month > 0 {
            return month == 1 ? "\(month)" + " " + "month ago" :
                "\(month)" + " " + "months ago"
        } else if let day = interval.day, day > 0 {
            return day == 1 ? "\(day)" + " " + "day ago" :
                "\(day)" + " " + "days ago"
        }else if let hour = interval.hour, hour > 0{
            return hour == 1 ? "\(hour)" + " " + "hour ago" :
                "\(hour)" + " " + "hours ago"
        }else if let min = interval.minute, min > 0{
            return min == 1 ? "\(min)" + " " + "min ago" :
                "\(min)" + " " + "minutes ago"
        }else{
            return "a moment ago"
        }
        
    }
}

extension UITableView {
    
    func getCellFrom(sender : UIView,completion : @escaping (UITableViewCell,IndexPath)->()){
        var superview = sender.superview
        while let view = superview, !(view is UITableViewCell) {
            superview = view.superview
        }
        guard let cell = superview as? UITableViewCell else {
            return
        }
        guard let indexPath = self.indexPath(for: cell) else {
            return
        }
        completion(cell,indexPath)
    }
    
    func reloadData(completion:@escaping ()->()) {
        UIView.animate(withDuration: 0, animations: { self.reloadData() })
        { _ in completion() }
    }
    
    func scrollToBottom(){
        let lastSection = self.numberOfSections > 1 ? (self.numberOfSections - 1) : 0
        guard self.numberOfRows(inSection: lastSection) > 0 else {return}
        let lastRow = self.numberOfRows(inSection: lastSection) > 1 ? (self.numberOfRows(inSection: lastSection) - 1) : 0
        let indexPath = IndexPath(row: lastRow, section: lastSection)
        self.scrollToRow(at: indexPath, at: .bottom, animated: true)
    }
    
    func isCellVisible(section:Int, row: Int) -> Bool {
        guard let indexes = self.indexPathsForVisibleRows else {
            return false
        }
        return indexes.contains {$0.section == section && $0.row == row }
    }

    func scrollToTop() {
        
        DispatchQueue.main.async {
            let indexPath = IndexPath(row: 0, section: 0)
            self.scrollToRow(at: indexPath, at: .top, animated: false)
        }
    }
}

extension NSAttributedString {
    
    convenience init(htmlString html: String, font: UIFont? = nil, useDocumentFontSize: Bool = true) throws {
        let options: [NSAttributedString.DocumentReadingOptionKey : Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]
        
        let data = html.data(using: .utf8, allowLossyConversion: true)
        guard (data != nil), let fontFamily = font?.familyName, let attr = try? NSMutableAttributedString(data: data!, options: options, documentAttributes: nil) else {
            try self.init(data: data ?? Data(html.utf8), options: options, documentAttributes: nil)
            return
        }
        
        let fontSize: CGFloat? = useDocumentFontSize ? nil : font!.pointSize
        let range = NSRange(location: 0, length: attr.length)
        attr.enumerateAttribute(.font, in: range, options: .longestEffectiveRangeNotRequired) { attrib, range, _ in
            if let htmlFont = attrib as? UIFont {
                let traits = htmlFont.fontDescriptor.symbolicTraits
                var descrip = htmlFont.fontDescriptor.withFamily(fontFamily)
                
                if (traits.rawValue & UIFontDescriptor.SymbolicTraits.traitBold.rawValue) != 0 {
                    descrip = descrip.withSymbolicTraits(.traitBold)!
                }
                
                if (traits.rawValue & UIFontDescriptor.SymbolicTraits.traitItalic.rawValue) != 0 {
                    descrip = descrip.withSymbolicTraits(.traitItalic)!
                }
                
                attr.addAttribute(.font, value: UIFont(descriptor: descrip, size: fontSize ?? htmlFont.pointSize), range: range)
            }
        }
        
        self.init(attributedString: attr)
    }
    
}

extension String {
    
    var isValidUrl : Bool {
        if let url = URL(string: self) {
            return UIApplication.shared.canOpenURL(url)
        }
        return false
    }
    
    func htmlToAttributedString(fontSize : CGFloat = 18)-> NSAttributedString? {
        do {
            return try NSAttributedString(htmlString: self, font: UIFont(name: "Lato-Regular", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize, weight: .regular),useDocumentFontSize : false)
            
        } catch {
            return NSAttributedString()
        }
    }
    
    var htmlToString: String {
        return htmlToAttributedString(fontSize: 18)?.string ?? ""
    }
    
    func toDouble() -> Double {
        return NSString(string : self).doubleValue
    }
    
    func toInteger() -> Int {
        return NSString(string : self).integerValue
    }
    
    func toFloat() -> Float {
        return NSString(string : self).floatValue
    }
    var getYoutubeThumnailFromID : String {
        return "https://img.youtube.com/vi/\(self)/default.jpg"
    }
    func trimAll() -> String{
        return String(self.filter { !"\t\r\n".contains($0)})
    }
    
    var localizedWithLanguage : String{
        return NSLocalizedString(self, tableName: "Localizable", bundle: .main, value: self, comment: self)
    }
}

extension UITextView{
    
    func setPlaceholder(placeholder:String) {
        
        let placeholderLabel = UILabel()
        placeholderLabel.text = placeholder
        placeholderLabel.font = UIFont.italicSystemFont(ofSize: (self.font?.pointSize)!)
        placeholderLabel.sizeToFit()
        placeholderLabel.tag = 222
        placeholderLabel.frame.origin = CGPoint(x: 5, y: (self.font?.pointSize)! / 2)
        placeholderLabel.textColor = UIColor.lightGray
        placeholderLabel.isHidden = !self.text.isEmpty
        
        self.addSubview(placeholderLabel)
    }
    
    func checkPlaceholder() {
        let placeholderLabel = self.viewWithTag(222) as! UILabel
        placeholderLabel.isHidden = !self.text.isEmpty
    }
    
}

extension String {
    func trim() -> String {
        return trimmingCharacters(in: CharacterSet.whitespaces)
    }
    
    func range(from nsRange: NSRange) -> Range<String.Index>? {
        guard
            let from16 = utf16.index(utf16.startIndex, offsetBy: nsRange.location, limitedBy: utf16.endIndex),
            let to16 = utf16.index(from16, offsetBy: nsRange.length, limitedBy: utf16.endIndex),
            let from = String.Index(from16, within: self),
            let to = String.Index(to16, within: self)
            else { return nil }
        return from ..< to
    }
}

extension Collection where Iterator.Element == String {
    var initials: [String] {
        return map{String($0.prefix(1))}
    }
}

extension Encodable {
    
    /// Converting object to postable dictionary
    func toDictionary(_ encoder: JSONEncoder = JSONEncoder()) throws -> [String: Any] {
        let data = try encoder.encode(self)
        let object = try JSONSerialization.jsonObject(with: data)
        guard let json = object as? [String: Any] else {
            let context = DecodingError.Context(codingPath: [], debugDescription: "Deserialized object is not a dictionary")
            throw DecodingError.typeMismatch(type(of: object), context)
        }
        return json
    }
}


extension UINavigationController {
    
    private func doAfterAnimatingTransition(animated: Bool, completion: @escaping (() -> Void)) {
        
        if let coordinator = transitionCoordinator, animated {
            coordinator.animate(alongsideTransition: nil, completion: { _ in
                //self.addBounce()
                completion()
            })
        } else {
            DispatchQueue.main.async {
                //self.addBounce()
                completion()
            }
        }
    }
    
    func fadeToPush(_ viewController: UIViewController,completion: @escaping (() -> Void)) {
        let transition: CATransition = CATransition()
        transition.duration = 0.3
        transition.type = CATransitionType.fade
        view.layer.add(transition, forKey: nil)
        pushViewController(viewController: viewController, animated: false){
            completion()
        }
    }
    
    func fadeToPop(_ viewController: UIViewController,completion: @escaping (() -> Void)) {
        let transition: CATransition = CATransition()
        transition.duration = 0.3
        transition.type = CATransitionType.fade
        view.layer.add(transition, forKey: nil)
        popToViewController(viewController, animated: true){
            completion()
        }
    }
    
    func pushViewController(viewController: UIViewController, animated: Bool, completion: @escaping (() -> Void)) {
        
        pushViewController(viewController, animated: animated)
        doAfterAnimatingTransition(animated: animated, completion: completion)
    }
    
    func popToViewController(_ viewController: UIViewController, animated:Bool = true, completion: @escaping ()->()) {
        CATransaction.setCompletionBlock(completion)
        self.popToViewController(viewController, animated: animated)
        CATransaction.commit()
    }
    
    func popViewController(animated: Bool, completion: @escaping (() -> Void)) {
        popViewController(animated: animated)
        doAfterAnimatingTransition(animated: animated, completion: completion)
    }
    
    func popToRootViewController(animated: Bool, completion: @escaping (() -> Void)) {
        popToRootViewController(animated: animated)
        doAfterAnimatingTransition(animated: animated, completion: completion)
    }
    
    func getPreviousViewController() -> UIViewController? {
        let count = viewControllers.count
        guard count > 1 else { return nil }
        return viewControllers[count - 2]
    }
}

extension UITextView :UITextViewDelegate
{
    
    /// Resize the placeholder when the UITextView bounds change
    override open var bounds: CGRect {
        didSet {
            self.resizePlaceholder()
        }
    }
    
    func numberOfLines() -> Int{
        if let fontUnwrapped = self.font{
            return Int(self.contentSize.height / fontUnwrapped.lineHeight)
        }
        return 0
    }
    
    /// When the UITextView did change, show or hide the label based on if the UITextView is empty or not
    ///
    /// - Parameter textView: The UITextView that got updated
    public func textViewDidChange(_ textView: UITextView) {
        if let placeholderLabel = self.viewWithTag(100) as? UILabel {
            placeholderLabel.isHidden = self.text.count > 0
        }
    }
    
    /// Resize the placeholder UILabel to make sure it's in the same position as the UITextView text
    private func resizePlaceholder() {
        if let placeholderLabel = self.viewWithTag(100) as! UILabel? {
            let labelX = self.textContainer.lineFragmentPadding
            let labelY = self.textContainerInset.top - 2
            let labelWidth = self.frame.width - (labelX * 2)
            let labelHeight = placeholderLabel.frame.height
            
            placeholderLabel.frame = CGRect(x: labelX, y: labelY, width: labelWidth, height: labelHeight)
        }
    }
    
    /// Adds a placeholder UILabel to this UITextView
    private func addPlaceholder(_ placeholderText: String) {
        let placeholderLabel = UILabel()
        
        placeholderLabel.text = placeholderText
        placeholderLabel.sizeToFit()
        
        placeholderLabel.font = self.font
        placeholderLabel.textColor = UIColor.lightGray
        placeholderLabel.tag = 100
        
        placeholderLabel.isHidden = self.text.count > 0
        
        self.addSubview(placeholderLabel)
        self.resizePlaceholder()
        self.delegate = self
    }
}


extension UIViewController {
    
    func checkAndPushPop<T : UIViewController>(_ viewCon: T,needFadeAnim : Bool = false,navigationController : UINavigationController?,completion : ((UIViewController?)->())? = nil) {
        for vc in navigationController?.viewControllers ?? [UIViewController]() {
            print(vc)
            print(viewCon)
            if vc is T {
                if needFadeAnim{
                    navigationController?.fadeToPop(vc, completion: {
                        completion?(navigationController?.viewControllers.last)
                    })
                }else{
                    navigationController?.popToViewController(vc, animated: true) {
                        completion?(navigationController?.viewControllers.last)
                    }
                }
                return
            }
        }
        if needFadeAnim{
            navigationController?.fadeToPush(viewCon, completion: {
                completion?(navigationController?.viewControllers.last)
            })
        }else{
            navigationController?.pushViewController(viewController: viewCon, animated: true) {
                completion?(navigationController?.viewControllers.last)
            }
        }
    }
    
    func setDropDown(from : UIView,direction: DropDown.Direction = .any,completion : @escaping(String,Int)->()) -> DropDown{
        let dropDown = DropDown()
        dropDown.backgroundColor = .black
        dropDown.textColor = .white
        dropDown.anchorView = from
        dropDown.bottomOffset = CGPoint(x: 0, y: from.frame.height + 10)
        dropDown.topOffset = CGPoint(x: 0, y: -(from.frame.height + 10))
        dropDown.cornerRadius = 5
        dropDown.shadowOpacity = 0.5
        dropDown.shadowColor = .darkGray
        dropDown.shadowRadius = 20
        dropDown.direction = direction
        dropDown.selectionAction = { index, item in
            dropDown.hide()
            completion(item,index)
        }
        return dropDown
    }
    
    func showDropDown(with : [String]?,from : UIView, direction: DropDown.Direction = .top, completion : @escaping(String,Int)->()){
        guard let with = with else {return}
        let dropDown = DropDown()
        dropDown.dataSource = with
        dropDown.backgroundColor = .black
        dropDown.textColor = .white
        dropDown.anchorView = from
        dropDown.bottomOffset = CGPoint(x: 0, y: from.frame.height + 10)
        dropDown.topOffset = CGPoint(x: 0, y: -(from.frame.height + 10))
        dropDown.cornerRadius = 5
        dropDown.shadowOpacity = 0.5
        dropDown.shadowColor = .darkGray
        dropDown.shadowRadius = 20
        dropDown.direction = direction
        dropDown.show()
        dropDown.selectionAction = { index, item in
            dropDown.hide()
            completion(item,index)
        }
    }
    
    func createDropDown(with : [String]?,from : UIView, direction: DropDown.Direction = .top) -> DropDown?{
        let dropDown = DropDown()
        if let with = with{
            dropDown.dataSource = with
        }
        dropDown.backgroundColor = .white
        dropDown.anchorView = from
        dropDown.bottomOffset = CGPoint(x: 0, y: from.frame.height + 10)
        dropDown.topOffset = CGPoint(x: 0, y: -(from.frame.height + 10))
        dropDown.cornerRadius = 5
        dropDown.shadowOpacity = 0.5
        dropDown.shadowColor = .darkGray
        dropDown.shadowRadius = 20
        dropDown.direction = direction
        if let _ = with{
            dropDown.show()
        }
        return dropDown
    }
    
}

extension UIImage {
    
    func resized(withPercentage percentage: CGFloat) -> UIImage? {
        let canvasSize = CGSize(width: size.width * percentage, height: size.height * percentage)
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: canvasSize))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    func resizedTo1MB() -> UIImage? {
        guard let imageData = self.pngData() else { return nil }
        
        var resizingImage = self
        var imageSizeKB = Double(imageData.count) / 1000.0 // ! Or devide for 1024 if you need KB but not kB
        
        while imageSizeKB > 1000 { // ! Or use 1024 if you need KB but not kB
            guard let resizedImage = resizingImage.resized(withPercentage: 0.9),
                let imageData = resizedImage.pngData()
                else { return nil }
            
            resizingImage = resizedImage
            imageSizeKB = Double(imageData.count) / 1000.0 // ! Or devide for 1024 if you need KB but not kB
        }
        
        return resizingImage
    }
}
class DynamicCollectionView: UICollectionView {
    override func layoutSubviews() {
        super.layoutSubviews()
        if bounds.size != intrinsicContentSize() {
            invalidateIntrinsicContentSize()
        }
    }
    
    func intrinsicContentSize() -> CGSize {
        return self.contentSize
    }
}
extension UIImageView {
    
    
    
    public func imageFromServerURL(urlString: URL, defaultImage : String?) {
        if let di = defaultImage {
            self.image = UIImage(named: di)
        }
        
        URLSession.shared.dataTask(with: urlString, completionHandler: { (data, response, error) -> Void in
            
            if error != nil {
                print(error ?? "error")
                return
            }
            DispatchQueue.main.async(execute: { () -> Void in
                let image = UIImage(data: data!)
                self.image = image
            })
            
        }).resume()
    }
}

extension Date {
    
    func prettyStringWithJPGExtension()-> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM YY HH:mm:ss"
        var dateString = "IMG "
        dateString = dateString + dateFormatter.string(from: self)
        dateString = dateString + ".jpg"
        return dateString
    }
    
    func prettyStringWithMOVExtension()-> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM YY HH:mm:ss"
        var dateString = "MOV "
        dateString = dateString + dateFormatter.string(from: self)
        dateString = dateString + ".mov"
        return dateString
    }
    
    func dateOnly() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.YYYY"
        return "\(dateFormatter.string(from: self))"
    }
    
    func timeOnly() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        return "\(dateFormatter.string(from: self))"
    }
    
    func dateByAdding(seconds: Int?) -> Date? {
        if seconds == nil {
            return nil
        }
        let calendar = Calendar.current
        var components = DateComponents()
        components.second = seconds!
        return (calendar as NSCalendar).date(byAdding: components, to: self, options: NSCalendar.Options())
    }
    
    func isLaterThan(_ aDate: Date) -> Bool {
        let isLater = self.compare(aDate) == ComparisonResult.orderedDescending
        return isLater
    }
    
}

extension UITextField {
    
    enum Direction {
        case Left
        case Right
    }
    
    // add image to textfield
    func withImage(direction: Direction, image: UIImage, colorSeparator: UIColor, colorBorder: UIColor){
        let mainView = UIView(frame: CGRect(x: 0, y: 0, width: 55, height: 45))
        mainView.layer.cornerRadius = 22.5
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 45))
        view.backgroundColor = .white
        view.clipsToBounds = true
        view.layer.cornerRadius = 5
        view.layer.borderWidth = CGFloat(0.5)
        view.layer.borderColor = colorBorder.cgColor
        mainView.addSubview(view)
        
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        imageView.frame = CGRect(x: 12.0, y: 10.0, width: 24.0, height: 24.0)
        view.addSubview(imageView)
        
        let seperatorView = UIView()
        seperatorView.backgroundColor = colorSeparator
        mainView.addSubview(seperatorView)
        
        if(Direction.Left == direction){ // image left
            seperatorView.frame = CGRect(x: 45, y: 0, width: 5, height: 45)
            self.leftViewMode = .always
            self.leftView = mainView
        } else { // image right
            seperatorView.frame = CGRect(x: 0, y: 0, width: 5, height: 45)
            self.rightViewMode = .always
            self.rightView = mainView
        }
        view.layer.cornerRadius = view.frame.size.height/2
        mainView.layer.cornerRadius = mainView.frame.size.height/2
        self.layer.borderColor = colorBorder.cgColor
        self.layer.borderWidth = CGFloat(0.5)
        self.layer.cornerRadius = 22.5
    }
}


extension UIApplication {
    
var statusBarUIView: UIView? {
    if #available(iOS 13.0, *) {
        let tag = 38482
        let keyWindow = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
        if let statusBar = keyWindow?.viewWithTag(tag) {
            return statusBar
        } else {
            guard let statusBarFrame = keyWindow?.windowScene?.statusBarManager?.statusBarFrame else { return nil }
            let statusBarView = UIView(frame: statusBarFrame)
            statusBarView.tag = tag
            keyWindow?.addSubview(statusBarView)
            return statusBarView
        }
    } else if responds(to: Selector(("statusBar"))) {
        return value(forKey: "statusBar") as? UIView
    } else {
        return nil
    }
  }
}

extension UITapGestureRecognizer {

    func didTapAttributedTextInLabel(label: UILabel, inRange targetRange: NSRange) -> Bool {
        // Create instances of NSLayoutManager, NSTextContainer and NSTextStorage
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: CGSize.zero)
        let textStorage = NSTextStorage(attributedString: label.attributedText!)

        // Configure layoutManager and textStorage
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)

        // Configure textContainer
        textContainer.lineFragmentPadding = 0.0
        textContainer.lineBreakMode = label.lineBreakMode
        textContainer.maximumNumberOfLines = label.numberOfLines
        let labelSize = label.bounds.size
        textContainer.size = labelSize

        // Find the tapped character location and compare it to the specified range
        let locationOfTouchInLabel = self.location(in: label)
        let textBoundingBox = layoutManager.usedRect(for: textContainer)

        let textContainerOffset = CGPoint(x: (labelSize.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x, y: (labelSize.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y)

        let locationOfTouchInTextContainer = CGPoint(x: locationOfTouchInLabel.x - textContainerOffset.x, y: locationOfTouchInLabel.y - textContainerOffset.y)

        let indexOfCharacter = layoutManager.characterIndex(for: locationOfTouchInTextContainer, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)

        return NSLocationInRange(indexOfCharacter, targetRange)
    }
}



extension UIAlertController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIAlertController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}


extension String {

    func widthOfString(usingFont font: UIFont) -> CGFloat {
        let fontAttributes = [NSAttributedString.Key.font: font]
        let size = self.size(withAttributes: fontAttributes)
        return size.width
    }

    func heightOfString(usingFont font: UIFont) -> CGFloat {
        let fontAttributes = [NSAttributedString.Key.font: font]
        let size = self.size(withAttributes: fontAttributes)
        return size.height
    }

    func sizeOfString(usingFont font: UIFont) -> CGSize {
        let fontAttributes = [NSAttributedString.Key.font: font]
        return self.size(withAttributes: fontAttributes)
    }
}



extension UIViewController {
    func presentModalyViewController(from: UIViewController,isFullScreen : Bool = true ,present : UIViewController,completion :(()->Void)? = nil){
        if #available(iOS 13.0, *) {
            if isFullScreen{
                present.modalPresentationStyle = .overCurrentContext
                present.modalTransitionStyle = .coverVertical
            }else{
                present.isModalInPresentation = true
            }
        }else{
            present.modalPresentationStyle = .overCurrentContext
            present.modalTransitionStyle = .coverVertical
        }
        from.present(present, animated: true, completion: completion)
    }
    
    //here bool define user logged in or not.Loggedin = true
    
    @objc func checkAndProcessToLogin(from : UIViewController?,after : (()->())?){
        DispatchQueue.main.async {
            if CommonUserDefaults.accessInstance.isLogin(){
                after?()
            }else{
                let mainNav = Helper.getVcObject(vcName: .AuthNavigationController, StoryBoardName: .Main) as! AuthNavigationController
                Helper.replaceRootView(for: mainNav, animated: true)
            }
        }
    }
    
    //show alert for only display information
    func showSingleButtonAlertWithoutAction (title:String) {
        let alert = UIAlertController(title: title, message: "", preferredStyle: UIAlertController.Style.alert)
        //alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func showProgressBarInAlert(_ completion : @escaping (UIAlertController,UIProgressView) -> ()){
        let alertView = UIAlertController(title: "Please wait while we are processing your request.", message: "0 %", preferredStyle: .alert)
        var progressView = UIProgressView()
        self.present(alertView, animated: true, completion:{
            let margin:CGFloat = 23.0
            let rect = CGRect(x: margin, y: 88.0, width: alertView.view.frame.width - margin * 2.0 , height: 2.0)
            progressView = UIProgressView(frame: rect)
            progressView.tintColor = CommonColor.ButtonGradientFirst
            alertView.view.addSubview(progressView)
            completion(alertView,progressView)
        })
    }
    
    //show alert with Single Button action
    func showSingleButtonAlertWithAction (title:String,buttonTitle:String,message:String,completionHandler:@escaping () -> ()) {
        let blurEffect = UIBlurEffect(style: .light)
        let blurVisualEffectView = UIVisualEffectView(effect: blurEffect)
        blurVisualEffectView.frame = view.bounds
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.0) {
            let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: buttonTitle, style: UIAlertAction.Style.default, handler: { action in
                completionHandler()
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    //show alert with right action button
    func showTwoButtonAlertWithRightAction (title:String,buttonTitleLeft:String,buttonTitleRight:String,message: String,completionHandler:@escaping () -> ()) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: buttonTitleLeft, style: UIAlertAction.Style.default, handler: nil))
        alert.addAction(UIAlertAction(title: buttonTitleRight, style: UIAlertAction.Style.default, handler: { action in
            completionHandler()
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    //show alert with left action button
    func showTwoButtonAlertWithLeftAction (title:String,buttonTitleLeft:String,buttonTitleRight:String,message: String, completionHandler:@escaping () -> ()) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: buttonTitleLeft, style: UIAlertAction.Style.default, handler: { action in
            completionHandler()
        }))
        alert.addAction(UIAlertAction(title: buttonTitleRight, style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    //show alert with two action button
    func showTwoButtonAlertWithTwoAction (title:String,message: String? = "",buttonTitleLeft:String,buttonTitleRight:String,completionHandlerLeft:@escaping () -> (),completionHandlerRight:@escaping () -> ()) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: buttonTitleLeft, style: UIAlertAction.Style.default, handler: { action in
            completionHandlerLeft()
        }))
        alert.addAction(UIAlertAction(title: buttonTitleRight, style: UIAlertAction.Style.default, handler: { action in
            completionHandlerRight()
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func showSingleButtonWithMessage(title:String,message: String, buttonName: String)
    {
        
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: buttonName, style: UIAlertAction.Style.default, handler:nil))
        self.present(alert, animated: true, completion: nil)
        
        
    }
    
    func showImageOnAlert(title : String, image : UIImage){
        let showAlert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        let imageView = UIImageView(frame: CGRect(x: 10, y: 50, width: 250, height: 230))
        imageView.image = image
        showAlert.view.addSubview(imageView)
        let height = NSLayoutConstraint(item: showAlert.view ?? UIView(), attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 320)
        let width = NSLayoutConstraint(item: showAlert.view ?? UIView(), attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 250)
        showAlert.view.addConstraint(height)
        showAlert.view.addConstraint(width)
        showAlert.addAction(UIAlertAction(title: "Done", style: .default, handler: nil))
        self.present(showAlert, animated: true, completion: nil)
    }
    func getImage(fromUrl : String?) -> UIImage{
        if let url = fromUrl{
            if let data = try? Data(contentsOf: URL(string: url)!)
            {
                return UIImage(data: data)!
            }
        }
        return UIImage()
    }
    
    func noInternetShow()
    {
        self.showSingleButtonWithMessage(title: "No Network!", message: "No internet connection found. Check your internet connection or try again.", buttonName: "OK")
    }
    
    
    func alert (title:String){
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.0) {
            
            let alertController = UIAlertController(title: nil, message: title, preferredStyle: .alert)
            alertController.view.tintColor = UIColor.black
            self.present(alertController, animated: true, completion: nil)
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(2.0 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {() -> Void in
                alertController.dismiss(animated: true, completion: {() -> Void in
                    
                    
                })
            })
            
        }
    }
    func alertWithAction (title:String,completionHandler:@escaping () -> ()){
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.0) {
            
            let alertController = UIAlertController(title: nil, message: title, preferredStyle: .alert)
            alertController.view.tintColor = UIColor.black
            self.present(alertController, animated: true, completion: nil)
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(2.0 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {() -> Void in
                alertController.dismiss(animated: true, completion: {() -> Void in
                    
                    completionHandler()
                })
            })
            
        }
    }
    
    func isBetweenDates(fromDate: String, toDate: String, format: String = "yyyy-MM-dd") -> Bool {
        let fromDateObj = getDateObject(value: fromDate, inputFormat: format)
        let toDateObj = getDateObject(value: toDate, inputFormat: format)
        let now = Date()
        return (now <= toDateObj && now >= fromDateObj)
    }
    
    func getFormattedDate(strDate: String , inputFormat:String , outputFormat:String) -> String {
        
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = inputFormat
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = outputFormat
        let date: Date? = dateFormatterGet.date(from: strDate)
        if date == nil{
            return dateFormatterPrint.string(from: Date())
        }else{
            return dateFormatterPrint.string(from: date!)
        }
    }
    
    func getDateObject(value: String, inputFormat: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = inputFormat
        return dateFormatter.date(from: value) ?? Date()
    }
    
    func daySuffix(from date: Date) -> String {
        let calendar = Calendar.current
        let dayOfMonth = calendar.component(.day, from: date)
        switch dayOfMonth {
        case 1, 21, 31: return "st"
        case 2, 22: return "nd"
        case 3, 23: return "rd"
        default: return "th"
        }
    }
    
    func navBarHeight() -> CGFloat{
        return self.navigationController?.navigationBar.frame.height ?? 44
    }
    
    func getTimePicker(from : Any, on : UIViewController,minHour : Int? = 0, minMinute : Int? = 0, minSec : Int? =
        0,_ completion : @escaping (String)->()){
        //Formate Date
        let timePicker = UIDatePicker()
        timePicker.datePickerMode = .time
        //ToolBar
        let date: Date = Date()
        let gregorian: Calendar = Calendar(identifier:  .gregorian)
        var components: DateComponents = gregorian.dateComponents([.day,.month,.year], from: date)
        components.hour = minHour
        components.minute = minMinute
        components.second = minSec
        let startDate: Date = gregorian.date(from: components) ?? Date()
        components.hour = 24
        components.minute = 0
        components.second = 0
        let endDate: Date = gregorian.date(from: components) ?? Date()
        timePicker.minimumDate = startDate
        timePicker.maximumDate = endDate
        timePicker.setDate(startDate, animated: true)
        timePicker.reloadInputViews()
        var toolbar = UIToolbar()
        toolbar.sizeToFit()
        toolbar.barStyle = .default
        toolbar = UIToolbar.init(frame: CGRect.init(x: 0.0, y: UIScreen.main.bounds.size.height - 250, width: UIScreen.main.bounds.size.width, height: 50))
        timePicker.backgroundColor = UIColor.white
        timePicker.setValue(UIColor.black, forKey: "textColor")
        timePicker.autoresizingMask = .flexibleWidth
        timePicker.frame = CGRect(x: 0, y: UIScreen.main.bounds.height - 200, width: self.view.frame.width, height: 200)
        //done button & cancel button
        let done = UIButton(type: .system)
        done.tintColor = .blue
        done.setTitle("Done", for: .normal)
//        done.addAction(for: .touchUpInside) {
//            let formatter = DateFormatter()
//            formatter.timeStyle = .short
//            if let _ = from as? UITextField{
//                self.view.endEditing(true)
//            }else{
//                toolbar.isHidden = true
//                timePicker.isHidden = true
//            }
//            completion(formatter.string(from: timePicker.date))
//        }
        let doneButton = UIBarButtonItem(customView: done)
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancel = UIButton(type: .system)
//        cancel.addAction(for: .touchUpInside) {
//            if let _ = from as? UITextField{
//                self.view.endEditing(true)
//            }else{
//                toolbar.isHidden = true
//                timePicker.isHidden = true
//            }
//            completion("")
//        }
        cancel.setTitle("Cancel", for: .normal)
        cancel.tintColor = .red
        let cancelButton = UIBarButtonItem(customView: cancel)
        toolbar.setItems([cancelButton,spaceButton,doneButton], animated: false)
        if let txt = from as? UITextField{
            txt.inputAccessoryView = toolbar
            // add datepicker to textField
            txt.inputView = timePicker
        }else{
            self.view.endEditing(true)
            self.view.addSubview(toolbar)
            self.view.addSubview(timePicker)
        }
        toolbar.isHidden = false
        timePicker.isHidden = false
    }
    
    func getDatePicker(from : Any,format : String = "dd MMM,yyyy",on : UIViewController ,maxDate : Date? = nil, minDate : Date? = nil, _ completion : @escaping (String)->()){
        //Formate Date
        let StartDatePicker = UIDatePicker()
        StartDatePicker.datePickerMode = .date
        //ToolBar
        if maxDate != nil{
            StartDatePicker.maximumDate = maxDate
        }
        if minDate != nil{
            StartDatePicker.minimumDate = minDate
        }
        var toolbar = UIToolbar()
        toolbar.sizeToFit()
        toolbar.barStyle = .default
        toolbar = UIToolbar.init(frame: CGRect.init(x: 0.0, y: UIScreen.main.bounds.size.height - 250, width: UIScreen.main.bounds.size.width, height: 50))
        StartDatePicker.backgroundColor = UIColor.white
        StartDatePicker.setValue(UIColor.black, forKey: "textColor")
        StartDatePicker.autoresizingMask = .flexibleWidth
        StartDatePicker.frame = CGRect(x: 0, y: UIScreen.main.bounds.height - 200, width: self.view.frame.width, height: 200)
        //done button & cancel button
        let done = UIButton(type: .system)
        done.setTitle("Done", for: .normal)
        done.tintColor = .blue
//        done.addAction(for: .touchUpInside) {
//            let formatter = DateFormatter()
//            formatter.dateFormat = format
//            if let _ = from as? UITextField{
//                self.view.endEditing(true)
//            }else{
//                toolbar.isHidden = true
//                StartDatePicker.isHidden = true
//            }
//            completion(formatter.string(from: StartDatePicker.date))
//        }
        let doneButton = UIBarButtonItem(customView: done)
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancel = UIButton(type: .system)
//        cancel.addAction(for: .touchUpInside) {
//            if let _ = from as? UITextField{
//                self.view.endEditing(true)
//            }else{
//                toolbar.isHidden = true
//                StartDatePicker.isHidden = true
//            }
//            completion("")
//        }
        cancel.setTitle("Cancel", for: .normal)
        cancel.tintColor = .red
        let cancelButton = UIBarButtonItem(customView: cancel)
        toolbar.setItems([cancelButton,spaceButton,doneButton], animated: true)
        // add toolbar to textField
        if let txt = from as? UITextField{
            txt.inputAccessoryView = toolbar
            // add datepicker to textField
            txt.inputView = StartDatePicker
        }else{
            self.view.addSubview(toolbar)
            self.view.addSubview(StartDatePicker)
        }
        
        toolbar.isHidden = false
        StartDatePicker.isHidden = false
    }
    
}


extension UITableView {
    
    func reloadWithAnimation(){
        self.reloadData()
        let tableViewHeight = self.bounds.size.height
        let cells = self.visibleCells
        var delayCounter = 0
        for cell in cells {
            cell.transform = CGAffineTransform(translationX: 0, y: tableViewHeight)
        }
        for cell in cells {
            UIView.animate(withDuration: 1.3, delay: 0.05 * Double(delayCounter),usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
                cell.transform = CGAffineTransform.identity
            }, completion: nil)
            delayCounter += 1
        }
    }
    
    func indexPathIsValid(_ indexPath: IndexPath) -> Bool {
        let section = indexPath.section
        let row = indexPath.row
        return section < self.numberOfSections && row < self.numberOfRows(inSection: section)
    }
    
    func setEmptyView(title: String, message: String, messageImage: UIImage,imageTint : UIColor? = nil,titleColor : UIColor? = nil,messageColor : UIColor? = nil,titleFont : UIFont? = nil,messageFont : UIFont? = nil) {
        
        let emptyView = UIView(frame: CGRect(x: self.center.x, y: self.center.y, width: self.bounds.size.width, height: self.bounds.size.height))
        
        let messageImageView = UIImageView()
        let titleLabel = UILabel()
        let messageLabel = UILabel()
        messageImageView.tintColor = imageTint
        messageImageView.backgroundColor = .clear
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        messageImageView.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        
        titleLabel.textColor = titleColor ?? UIColor.black
        titleLabel.font = titleFont ?? UIFont(name: "HelveticaNeue-Bold", size: 18)
        titleLabel.textAlignment = .center
        messageLabel.textColor = messageColor ?? UIColor.lightGray
        messageLabel.font = messageFont ?? UIFont(name: "HelveticaNeue-Regular", size: 15)
        messageLabel.textAlignment = .center
        emptyView.addSubview(titleLabel)
        emptyView.addSubview(messageImageView)
        emptyView.addSubview(messageLabel)
        
        messageImageView.centerXAnchor.constraint(equalTo: emptyView.centerXAnchor).isActive = true
        messageImageView.centerYAnchor.constraint(equalTo: emptyView.centerYAnchor, constant: -20).isActive = true
        messageImageView.widthAnchor.constraint(equalToConstant: 70).isActive = true
        messageImageView.heightAnchor.constraint(equalToConstant: 70).isActive = true
        
        titleLabel.topAnchor.constraint(equalTo: messageImageView.bottomAnchor, constant: 10).isActive = true
        titleLabel.centerXAnchor.constraint(equalTo: emptyView.centerXAnchor).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: emptyView.leadingAnchor, constant: 20).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: emptyView.trailingAnchor, constant: -20).isActive = true
        messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10).isActive = true
        messageLabel.centerXAnchor.constraint(equalTo: emptyView.centerXAnchor).isActive = true
        messageLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor, constant: 0).isActive = true
        messageLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 0).isActive = true
        messageImageView.image = messageImage
        titleLabel.text = title
        messageLabel.text = message
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        UIView.animate(withDuration: 1, animations:{
            messageImageView.transform = CGAffineTransform(rotationAngle: .pi / 10)
        }, completion: { (finish) in
            UIView.animate(withDuration: 1, animations:{
                messageImageView.transform = CGAffineTransform(rotationAngle: -1 * (.pi / 10))
            }, completion: { (finishh) in
                UIView.animate(withDuration: 1, animations: {
                    messageImageView.transform = CGAffineTransform.identity
                })
            })
            
        })
        self.backgroundView = emptyView
        self.separatorStyle = .none
    }
    
    func restore() {
        self.backgroundView = nil
    }
    
}

extension UIScrollView {
    
    func scrollViewToTop() {
        let desiredOffset = CGPoint(x: 0, y: -contentInset.top)
        setContentOffset(desiredOffset, animated: true)
    }
}



extension UICollectionView {
    
    func setEmptyView(title: String, message: String, messageImage: UIImage,imageTint : UIColor? = nil,titleColor : UIColor? = nil,messageColor : UIColor? = nil,titleFont : UIFont? = nil,messageFont : UIFont? = nil) {
        
        let emptyView = UIView(frame: CGRect(x: self.center.x, y: self.center.y, width: self.bounds.size.width, height: self.bounds.size.height))
        
        let messageImageView = UIImageView()
        let titleLabel = UILabel()
        let messageLabel = UILabel()
        if let tint = imageTint{
            messageImageView.tintColor = tint
        }
        messageImageView.backgroundColor = .clear
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        messageImageView.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        
        titleLabel.textColor = titleColor ?? UIColor.black
        titleLabel.font = titleFont ?? UIFont(name: "HelveticaNeue-Bold", size: 18)
        titleLabel.minimumScaleFactor = 0.6
        
        messageLabel.textColor = messageColor ?? UIColor.lightGray
        messageLabel.font = messageFont ?? UIFont(name: "HelveticaNeue-Regular", size: 15)
        messageLabel.minimumScaleFactor = 0.6
        emptyView.addSubview(titleLabel)
        emptyView.addSubview(messageImageView)
        emptyView.addSubview(messageLabel)
        
        messageImageView.centerXAnchor.constraint(equalTo: emptyView.centerXAnchor).isActive = true
        messageImageView.centerYAnchor.constraint(equalTo: emptyView.centerYAnchor, constant: -20).isActive = true
        messageImageView.widthAnchor.constraint(equalToConstant: 80).isActive = true
        messageImageView.heightAnchor.constraint(equalToConstant: 80).isActive = true
        
        titleLabel.topAnchor.constraint(equalTo: messageImageView.bottomAnchor, constant: 10).isActive = true
        titleLabel.centerXAnchor.constraint(equalTo: emptyView.centerXAnchor).isActive = true
        
        messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10).isActive = true
        messageLabel.centerXAnchor.constraint(equalTo: emptyView.centerXAnchor).isActive = true
        
        messageImageView.image = messageImage
        titleLabel.text = title
        messageLabel.text = message
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        
        UIView.animate(withDuration: 1, animations: {
            
            messageImageView.transform = CGAffineTransform(rotationAngle: .pi / 10)
        }, completion: { (finish) in
            UIView.animate(withDuration: 1, animations: {
                messageImageView.transform = CGAffineTransform(rotationAngle: -1 * (.pi / 10))
            }, completion: { (finishh) in
                UIView.animate(withDuration: 1, animations: {
                    messageImageView.transform = CGAffineTransform.identity
                })
            })
            
        })
        self.backgroundView = emptyView
    }
    
    func restore() {
        self.backgroundView = nil
    }
}

extension UITextField {
    
   @IBInspectable var placeHolderUpdateColor: UIColor? {
        get {
            return self.placeHolderUpdateColor
        }
        set {
            self.attributedPlaceholder = NSAttributedString(string:self.placeholder != nil ? self.placeholder! : "", attributes:[NSAttributedString.Key.foregroundColor: newValue!])
        }
    }
}

extension UILabel {
    func castShadow(color: CGColor = UIColor.black.cgColor, radius: CGFloat = 5, opacity: Float = 0.2, offset: CGSize = CGSize.zero) {
        layer.masksToBounds = false
        layer.shadowColor = color
        layer.shadowRadius = radius
        layer.shadowOpacity = opacity
        layer.shadowOffset = CGSize(width: 5, height: 5)
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
//        shadowColor = .black
//        shadowOffset = CGSize(width: 5, height: 5)
    }
}
