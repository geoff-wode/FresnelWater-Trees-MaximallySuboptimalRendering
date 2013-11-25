using System;

using Microsoft.Xna.Framework;
using Microsoft.Xna.Framework.Graphics;

using Idyll;
using Idyll.Input;
using Idyll.SceneGraph;

namespace Meadow
{
    static class Program
    {
        static TheGame game;
        /// <summary>
        /// The main entry point for the application.
        /// </summary>
        static void Main(string[] args)
        {
            using (game = new TheGame(1280, 960))
            {
                InputController input = new InputController(game);
                game.Components.Add(input);

                input.OnKeyUp += new EventHandler<KeyEventArgs>(input_OnKeyUp);

                FPSCamera camera = new FPSCamera(game);
                game.Components.Add(camera);
                camera.Position = new Vector3(127, 0, 127);

                Scene scene = new Scene(game);
                game.Components.Add(scene);

                SceneNode weather = new SceneNode();
                SceneNode geology = new SceneNode();

                scene.RootNode.AddNode(weather);
                scene.RootNode.AddNode(geology);

                weather.AddNode(new Weather.Sun());
                weather.AddNode(new Weather.SkyDome());

                Random rand = new Random();
                Vector3 windDir = Vector3.Transform(Vector3.UnitX, Matrix.CreateRotationY(MathHelper.ToRadians(rand.Next(360))));
                weather.AddNode(new Weather.Wind(MathHelper.Lerp(0.001f, 0.0025f, (float)rand.NextDouble()), windDir));

                geology.AddNode(new Geology.Terrain());

                Geology.Water water = new Meadow.Geology.Water();
                geology.AddNode(water);

                scene.AddPreProcessor(water);
                scene.AddPostProcessor(water);

                SceneNode nature = new SceneNode();
                scene.RootNode.AddNode(nature);

                nature.AddNode(new TreeNode());

                game.Run();
            }
        }

        static void input_OnKeyUp(object sender, KeyEventArgs e)
        {
            if (e.Key == Microsoft.Xna.Framework.Input.Keys.Escape)
            {
                game.Exit();
            }
        }
    }

    class TreeNode : SceneNode
    {
        public override void LoadContent(Scene scene, Microsoft.Xna.Framework.Content.ContentManager contentManager)
        {
            Geology.ITerrainInfo terrain = (Geology.ITerrainInfo)scene.Game.Services.GetService(typeof(Geology.ITerrainInfo));

            Random rand = new Random();

            for (int i = 0; i < 200; i++)
            {
                float x, y, z;

                // TODO: Use some algorithm or seeding texture to plant trees.
                //       Also, pre-compute positions.
                do
                {
                    x = MathHelper.Lerp(-terrain.MapWidth / 3, terrain.MapWidth / 3, (float)rand.NextDouble());
                    z = MathHelper.Lerp(-terrain.MapLength / 3, terrain.MapLength / 3, (float)rand.NextDouble());
                    y = terrain.GetHeightAt(x, z);
                } while (y < 8);

                Matrix toWorld = Matrix.CreateTranslation(x, y - 0.5f, z);

                this.AddNode(new ModelNode("Models/Nature/tree", toWorld));
            }

            base.LoadContent(scene, contentManager);
        }
    }
}
