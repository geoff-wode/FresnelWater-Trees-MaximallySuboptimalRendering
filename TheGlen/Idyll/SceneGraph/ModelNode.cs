using System;
using System.Collections.Generic;
using Microsoft.Xna.Framework;
using Microsoft.Xna.Framework.Content;
using Microsoft.Xna.Framework.Graphics;

namespace Idyll.SceneGraph
{
    public class ModelNode : TransformNode
    {
        private string modelName;
        private Model model;
        private Matrix[] bones;
        private Texture2D texture;
        private Effect effect;

        public ModelNode(string modelName, Matrix toWorld)
            : base(toWorld)
        {
            this.modelName = modelName;
        }

        public override void LoadContent(Scene scene, ContentManager contentManager)
        {
            effect = contentManager.Load<Effect>("Effects/Textured");

            model = contentManager.Load<Model>(modelName);
            bones = new Matrix[model.Bones.Count];
            model.CopyAbsoluteBoneTransformsTo(bones);

            foreach (ModelMesh mesh in model.Meshes)
            {
                foreach (ModelMeshPart part in mesh.MeshParts)
                {
                    part.Effect = effect.Clone();
                }
            }

            texture = contentManager.Load<Texture2D>("Textures/Nature/tree_uv");

            base.LoadContent(scene, contentManager);
        }

        public override void Render(Scene scene, GraphicsDevice graphicsDevice)
        {
            foreach (ModelMesh mesh in model.Meshes)
            {
                foreach (Effect e in mesh.Effects)
                {
                    e.CurrentTechnique = e.Techniques["Textured"];
                    e.Parameters["World"].SetValue(bones[mesh.ParentBone.Index] * scene.MatrixStack.Peek());
                    e.Parameters["Texture"].SetValue(texture);
                }
                mesh.Draw();
            }

            base.Render(scene, graphicsDevice);
        }
    }
}
