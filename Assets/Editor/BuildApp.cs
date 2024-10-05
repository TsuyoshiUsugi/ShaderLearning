using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

public class BuildApp : MonoBehaviour
{
    [MenuItem("Build/BuildApp")]
    public static void Build()
    {
        //windows64のプラットフォームでアプリをビルドする
        BuildPipeline.BuildPlayer(
            new string[] { "Assets/Scenes/SampleScene.unity" },
            "Builds/App/SampleApp.exe",
            BuildTarget.StandaloneWindows64,
            BuildOptions.None
        );
    }
}
