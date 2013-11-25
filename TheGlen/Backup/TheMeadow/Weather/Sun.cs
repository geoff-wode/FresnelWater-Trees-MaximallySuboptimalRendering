using System;
using System.Collections.Generic;
using System.Linq;
using Microsoft.Xna.Framework;
using Microsoft.Xna.Framework.Audio;
using Microsoft.Xna.Framework.Content;
using Microsoft.Xna.Framework.GamerServices;
using Microsoft.Xna.Framework.Graphics;
using Microsoft.Xna.Framework.Input;
using Microsoft.Xna.Framework.Media;
using Microsoft.Xna.Framework.Net;
using Microsoft.Xna.Framework.Storage;

using Idyll.SceneGraph;

namespace Meadow.Weather
{
    /// <summary>
    /// This is a game component that implements IUpdateable.
    /// </summary>
    public class Sun : SceneNode
    {
        public Vector3 Direction { get; private set; }

        public override void Initialise()
        {
            Direction = new Vector3(0.5f, -0.4f, -0.25f);

            base.Initialise();
        }

        public override void LoadContent(Scene scene, ContentManager contentManager)
        {
            scene.Game.Services.AddService(typeof(Sun), this);
            base.LoadContent(scene, contentManager);
        }

        public override void Update(Scene scene, GameTime gameTime)
        {
            // TODO: Use the passing of time to alter the sun...

            base.Update(scene, gameTime);
        }

        public override void Render(Scene scene, GraphicsDevice graphicsDevice)
        {
            scene.CommonParamEffect.Parameters["SunDirection"].SetValue(Direction);
            base.Render(scene, graphicsDevice);
        }
    }
}