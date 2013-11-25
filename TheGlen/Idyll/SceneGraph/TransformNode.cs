using System;
using System.Collections.Generic;
using Microsoft.Xna.Framework;

namespace Idyll.SceneGraph
{
    public class TransformNode : SceneNode
    {
        protected Matrix toWorld;

        public TransformNode()
            : this(Matrix.Identity)
        {
        }

        public TransformNode(Matrix toWorld)
        {
            this.toWorld = toWorld;
        }

        public override bool PreRender(Scene scene, Microsoft.Xna.Framework.Graphics.GraphicsDevice graphicsDevice)
        {
            scene.MatrixStack.Push(toWorld * scene.MatrixStack.Peek());
            return base.PreRender(scene, graphicsDevice);
        }

        public override void PostRender(Scene scene, Microsoft.Xna.Framework.Graphics.GraphicsDevice graphicsDevice)
        {
            scene.MatrixStack.Pop();
            base.PostRender(scene, graphicsDevice);
        }
    }
}
