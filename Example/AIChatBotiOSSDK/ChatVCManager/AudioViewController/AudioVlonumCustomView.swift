
import UIKit

class AudioVlonumCustomView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    var all_animate_view = [WaveformView]()
    func initUI(){
        for i in 0..<100{
            let animate_view = WaveformView(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
            animate_view.zhengfu_lv = 1.0-Double(i)*0.7/100
            self.addSubview(animate_view)
            all_animate_view.append(animate_view)
        }
    }
    func updateCurrentVolumeNmber(volumeNumber: Float){
        var final_volumeNumber = volumeNumber
        if volumeNumber >= 1.0{
            final_volumeNumber = 1.0
        }else if volumeNumber <= 0.0{
            final_volumeNumber = 0
        }
        for value in all_animate_view{
            value.updateNewPoit(newFloat: final_volumeNumber)
        }
    }
}
class WaveformView: UIView {
    var allPoints_Float = [Float]()
    var zhengfu_lv = 1.0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func updateNewPoit(newFloat: Float){
        allPoints_Float.append(newFloat)
        self.setNeedsDisplay()
    }
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        if allPoints_Float.count > 10{
            allPoints_Float.removeFirst()
        }
        if allPoints_Float.count <= 1{
            return
        }
        guard let context = UIGraphicsGetCurrentContext() else { return }
        context.setLineWidth(2.0)
        context.setStrokeColor(UIColor(red: 96/255, green: 196/255, blue: 71/255, alpha: 1).cgColor)
        let path = UIBezierPath()
        
        for i in 0..<allPoints_Float.count-1{
            if i >= 1{
                let secondPoit = CGPoint(x: Double(30*(i)), y: 50.0)
                path.addLine(to: secondPoit)
            }
            let firstPoit = CGPoint(x: Double(30*i), y: 50.0)
            let secondPoit = CGPoint(x: Double(30*(i+1)), y: 50.0)
            let amplitude: CGFloat = CGFloat(abs(allPoints_Float[i+1]-allPoints_Float[i])*100.0/2.0)*zhengfu_lv
            let frequency: CGFloat = 2.0
            let deltaX = secondPoit.x - firstPoit.x
            for x in stride(from: firstPoit.x, to: secondPoit.x, by: 1) {
                let normalizedX = (x - firstPoit.x) / deltaX
                let y = firstPoit.y + amplitude * sin(frequency * normalizedX * 2 * .pi)
                if x == firstPoit.x {
                    path.move(to: CGPoint(x: x, y: y))
                }else{
                    path.addLine(to: CGPoint(x: x, y: y))
                }
            }
        }
        path.stroke()
    }
}
