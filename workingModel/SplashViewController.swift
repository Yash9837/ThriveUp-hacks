import UIKit

class SplashViewController: UIViewController {
    
    // MARK: - UI Elements
    
    private let logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "thriveUpLogo") // Replace "logo" with your actual logo image name
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let appNameLabel: UILabel = {
        let label = UILabel()
        label.text = "ThriveUp" // Replace with your app name
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 46)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hex: "#FF5900") // Darker Orange
        setupUI()
        animateSplashTransition()
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        // Add logo and app name to the view
        view.addSubview(logoImageView)
        view.addSubview(appNameLabel)
        
        // Set constraints for logo and app name
        NSLayoutConstraint.activate([
            // Logo constraints
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.bottomAnchor.constraint(equalTo: appNameLabel.topAnchor, constant: -20),
            logoImageView.widthAnchor.constraint(equalToConstant: 120), // Adjust size as needed
            logoImageView.heightAnchor.constraint(equalToConstant: 120), // Adjust size as needed
            
            // App name constraints
            appNameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            appNameLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    // MARK: - Animation
    
    private func animateSplashTransition() {
        UIView.animate(withDuration: 2, delay: 0.5, options: [.curveEaseInOut], animations: {
            // Transition background color to white
            self.view.backgroundColor = .white
            // Fade out the logo and label
            self.logoImageView.alpha = 0.0
            self.appNameLabel.alpha = 0.0
        }) { _ in
            // After animation, transition to onboarding
            self.transitionToOnboarding()
        }
    }
    
    // MARK: - Transition
    
    // MARK: - Transition to Onboarding
    // MARK: - Transition to Onboarding
    // MARK: - Transition to Onboarding
    private func transitionToOnboarding() {
        // Initialize the iOSOnboardingViewController (no need to initialize a new UIPageViewController)
        let onboardingPageViewController = iOSOnboardingViewController()
        
        // Get the key window
        let window = UIApplication.shared.windows.first { $0.isKeyWindow }
        
        // Transition to the onboarding page
        UIView.transition(with: window!,
                          duration: 0.5,
                          options: .transitionCrossDissolve,
                          animations: {
            window?.rootViewController = onboardingPageViewController
        }, completion: nil)
    }



}

// MARK: - UIColor Extension for Hex

extension UIColor {
    convenience init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)
        
        let red = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgb & 0x0000FF) / 255.0
        
        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }
}
