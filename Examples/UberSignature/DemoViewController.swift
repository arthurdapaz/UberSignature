/**
 Copyright (c) 2017 Uber Technologies, Inc.
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 */

import UIKit
import UberSignature

class DemoViewController: UIViewController, SignatureDrawingViewControllerDelegate {

    private let signatureViewController = SignatureDrawingViewController()

    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var saveImageButton: UIButton!
    @IBOutlet weak var savePdfButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        setupSignatureView()
    }

    func setupSignatureView() {
        addChildViewController(signatureViewController)
        view.addSubview(signatureViewController.view)
        signatureViewController.view.translatesAutoresizingMaskIntoConstraints = false
        signatureViewController.view.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        signatureViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        signatureViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        signatureViewController.view.bottomAnchor.constraint(equalTo: stackView.topAnchor).isActive = true
        signatureViewController.didMove(toParentViewController: self)

        signatureViewController.delegate = self
    }

    // MARK: SignatureDrawingViewControllerDelegate
    func signatureDrawingViewControllerIsEmptyDidChange(controller: SignatureDrawingViewController, isEmpty: Bool) {
        resetButton.isHidden = isEmpty
        savePdfButton.isHidden = isEmpty
        saveImageButton.isHidden = isEmpty
    }


    @IBAction func resetAction(_ sender: Any) {
        signatureViewController.reset()
    }

    @IBAction func saveImage(_ sender: Any) {

        guard let signatureImage = signatureViewController.fullSignatureImage else { return }
        
        UIImageWriteToSavedPhotosAlbum(signatureImage, nil, nil, nil)

    }

    var activityViewController: UIActivityViewController!

    @IBAction func safePDF(_ sender: Any) {
        guard let signaturePDF = signatureViewController.fullSignaturePDF else { return }

        let temporary = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        let pdfPath = temporary.appendingPathComponent("Signature.pdf")
        try! signaturePDF.write(to: pdfPath)

//        FileManager.default.createFile(atPath: pdfPath.path, contents: signaturePDF, attributes: [.type : "application/pdf"])


        activityViewController = UIActivityViewController(activityItems: [pdfPath], applicationActivities: nil)
        activityViewController.modalPresentationStyle = .popover
        if let controller = activityViewController.popoverPresentationController {

            controller.sourceView = saveImageButton
            controller.permittedArrowDirections = .down
        }
        present(activityViewController, animated: true)

    }

}
