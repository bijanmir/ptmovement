import UIKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        // For testing - launch directly into exercise
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let exerciseVC = ExerciseViewController(exercise: Exercise.shoulderRaise)
            exerciseVC.modalPresentationStyle = .fullScreen
            self.present(exerciseVC, animated: true)
        }
    }
}
