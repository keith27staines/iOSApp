//
//  F4DOcumentCaptureViewController.swift
//  DocumentCapture
//
//  Created by Keith Dev on 09/06/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import UIKit

protocol F4SCameraCaptureViewControllerDelegate : class {
    func didCaptureDocumentasPDFData(_ data: Data)
}

class F4SCameraPageManagerViewController: UIViewController {

    weak var delegate: F4SCameraCaptureViewControllerDelegate?
    
    var camera: F4SCameraViewController?
    var arranger: F4SArrangeTableViewController?
    var displayer: F4SDisplayTableViewController?
    var minArrangeWidth: CGFloat = 24
    var maxArrangeWidth: CGFloat = 128
    
    @IBOutlet weak var introductionView: UIView!
    
    @IBOutlet weak var arrangeButton: UIBarButtonItem!
    
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    @IBOutlet weak var arrangeContainer: UIView!
    
    @IBOutlet weak var displayContainer: UIView!
    
    @IBOutlet weak var arrangeWidthConstraint: NSLayoutConstraint!
    
    @IBAction func toggleArrangeMode(_ sender: UIBarButtonItem) {
        arranging = !arranging
    }
    
    @IBAction func add(_sender: Any) {
        performSegue(withIdentifier: "camera", sender: self)
    }
    
    @IBAction func done(_ sender: Any) {
        let data = documentModel.generatePDF()
        delegate?.didCaptureDocumentasPDFData(data)
    }
    
    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    var arranging: Bool = false {
        didSet {
            arrangeWidthConstraint.constant = arranging ? maxArrangeWidth : minArrangeWidth
            if arranging {
                // If we are going from non-arranging to arrangine, then the animation looks better if the table's isEditing property is set to true before the animation. In the reverse situation, it is better to set the isEditing property in the finished handler of the animation
                arranger?.isEditing = true
            }
            UIView.animate(withDuration: 0.4, delay: 0.0, options: .curveEaseInOut, animations: { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.view.layoutIfNeeded()
                
            }) { [weak self] (finished) in
                guard let strongSelf = self else { return }
                strongSelf.arranger?.isEditing = strongSelf.arranging
                if !strongSelf.arranging {
                    strongSelf.arranging = false
                }
            }
        }
    }
    
    lazy var documentModel: F4SMultiPageDocument = {
        return F4SMultiPageDocument()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupForPageCount(count: documentModel.pageCount, isInitialSetup: true)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? F4SDocumentTableViewController {
            vc.multiPageModel = documentModel
            if let arranger = vc as? F4SArrangeTableViewController {
                self.arranger = arranger
                arranger.delegate = self
                return
            }
            if let displayer = vc as? F4SDisplayTableViewController {
                self.displayer = displayer
                return
            }
        }
        if let nav = segue.destination as? UINavigationController {
            if let camera = nav.topViewController as? F4SCameraViewController {
                camera.capturedImage = nil
                camera.delegate = self
                self.camera = camera
                return
            }
        }
    }
    
    func setupForPageCount(count: Int, isInitialSetup: Bool = false) {
        arrangeButton.isEnabled = count > 0
        doneButton.isEnabled = count > 0
        if count == 0 {
            showIntroductionView()
            arranging = false
        } else {
            hideIntroductionView()
        }
    }
    
    func hideIntroductionView() {
        if introductionView.isHidden { return }
        UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseInOut, animations: { [weak self] in
            self?.introductionView.alpha = 0.1
        }) { [weak self] (finished) in
            self?.introductionView.isHidden = true
        }
    }
    
    func showIntroductionView() {
        if !introductionView.isHidden { return }
        introductionView.alpha = 0.0
        introductionView.isHidden = false
        UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseInOut, animations: { [weak self] in
            self?.introductionView.alpha = 1.0
        })
    }
    
}

extension F4SCameraPageManagerViewController: F4SArrangeTableViewControllerDelegate {
    func arranger(_ arranger: F4SArrangeTableViewController, didSelectRowAtIndexPath indexPath: IndexPath) {
        displayer?.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
    }
    func arrangerCountChanged(_ arranger: F4SArrangeTableViewController, count: Int) {
        setupForPageCount(count: count)
    }
}

extension F4SCameraPageManagerViewController : F4SCameraViewControllerDelegate {
    func cameraCaptureDidComplete(controller: F4SCameraViewController, image: UIImage?) {
        guard let image = image else {
            return
        }
        let page = F4SDocumentPage(text: "")
        page.image = image
        documentModel.append(page)
    }
}

class F4SDocumentPage {
    var image: UIImage
    init(text: String) {
        image = F4SDocumentPage.createImage(text: text)
    }
    
    static func createImage(text: String) -> UIImage {
        let width: CGFloat = 1000
        let height:CGFloat = 1000 * 1.4142
        let bounds = CGRect(x: 0, y: 0, width: width, height: height)
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        let image = renderer.image { (rendererContext) in
            let context = rendererContext.cgContext
            let rectangle = CGRect(x: 0, y: 0, width: width, height: height)
            context.setFillColor(UIColor.lightGray.cgColor)
            context.setStrokeColor(UIColor.black.cgColor)
            context.setLineWidth(6)
            context.addRect(rectangle)
            context.drawPath(using: .fillStroke)
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .left
            let attrs = [NSAttributedString.Key.font: UIFont(name: "HelveticaNeue", size: 1000)!, NSAttributedString.Key.paragraphStyle: paragraphStyle]
            context.setFillColor(UIColor.black.cgColor)
            text.draw(with: CGRect(x: 10, y: 10, width: 980, height: 1380), options: .usesLineFragmentOrigin, attributes: attrs, context: nil)
        }
        return image
    }
}











