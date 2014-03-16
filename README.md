MKInteractionCoordinator
========================

With iOS 7 supporting interactive transitions, I often find myself writing code in view controllers to provide UIPercentDrivenInteractiveTransition. I wrote the class MKTransitionCoordinator to manage interactive transitions as well as animated transitions. All the code is kept in MKTransitionCoordinator class. The source view controller only needs to initialize it's object and provide the destination view controller via the delegate method. The delegate method provide the location of user interaction. This can be used to provide a different destination based on a certain criteria. The same implementation doesn't provide any fancy transition code, but a skeleton to manage animated and interactive transitions. 
