//
//  TrailingShader.swift
//  astral
//
//  Created by Joseph Haygood on 5/2/23.
//

import Foundation
import SpriteKit

class TrailShaderNode: SKShader {
    
    init(trailLength: CGFloat, color: SKColor) {
        let uniforms = [
            SKUniform(name: "u_color"),
            SKUniform(name: "u_tail_length", float: Float(trailLength))
        ]
        
        let source = """
            void main()
            {
                vec2 position = vec2(0.5, 0.5) - v_tex_coord;
                float alpha = clamp(1.0 - length(position) * u_tail_length, 0.0, 1.0);
                gl_FragColor = u_color * alpha;
            }
            """
        
        super.init(source: source, uniforms: uniforms)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
