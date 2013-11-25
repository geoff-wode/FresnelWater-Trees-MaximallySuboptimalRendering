using System;
using System.Collections.Generic;
using Microsoft.Xna.Framework;
using Microsoft.Xna.Framework.Graphics;
using Microsoft.Xna.Framework.Content;

using Idyll;
using Idyll.SceneGraph;

namespace Meadow.Weather
{
    public class Wind : SceneNode
    {
        private float windSpeed;
        private Vector3 windDirection;

        public Wind()
            : this(20.0f, new Vector3(1, 0, 0))
        {
        }

        public Wind(float speed, Vector3 direction)
        {
            this.windSpeed = speed;
            this.windDirection = direction;
        }

        public override void Render(Scene scene, GraphicsDevice graphicsDevice)
        {
            scene.CommonParamEffect.Parameters["WindSpeed"].SetValue(windSpeed);
            scene.CommonParamEffect.Parameters["WindDirection"].SetValue(windDirection);

            base.Render(scene, graphicsDevice);
        }
    }
}
