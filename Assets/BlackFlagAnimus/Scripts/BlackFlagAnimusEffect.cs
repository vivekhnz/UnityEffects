using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BlackFlagAnimusEffect : MonoBehaviour
{
    public Color WireframeBackgroundColor = Color.black;
    public Color WireframeLineColor = Color.white;

    private Camera attachedCamera;
    private Camera wireframeCam;

    private RenderTexture wireframeRT;
    private Shader wireframeShader;
    private Material compositeMat;

    /// <summary>
    /// Start is called on the frame when a script is enabled just before
    /// any of the Update methods is called the first time.
    /// </summary>
    void Start()
    {
        attachedCamera = GetComponent<Camera>();

        // create render texture to store the wireframe texture in
        wireframeRT = new RenderTexture(Screen.width, Screen.height, 0);

        // add a temporary camera that renders the scene in wireframe mode
        wireframeCam = new GameObject().AddComponent<Camera>();
        wireframeCam.name = "Wireframe Camera (Animus)";

        // load and configure wireframe shader
        wireframeShader = Shader.Find("Custom/BlackFlagAnimus/Wireframe");
        Shader.SetGlobalColor("_WireframeBackgroundColor", WireframeBackgroundColor);
        Shader.SetGlobalColor("_WireframeLineColor", WireframeLineColor);

        // create shader material
        var compositeShader = Shader.Find("Custom/BlackFlagAnimus/Composite");
        compositeMat = new Material(compositeShader);
        compositeMat.SetTexture("_WireframeTex", wireframeRT);
        compositeMat.SetColor("_BackgroundColor", WireframeBackgroundColor);
    }

    /// <summary>
    /// OnRenderImage is called after all rendering is complete to render image.
    /// </summary>
    /// <param name="src">The source RenderTexture.</param>
    /// <param name="dest">The destination RenderTexture.</param>
    void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        wireframeCam.CopyFrom(attachedCamera);
        wireframeCam.backgroundColor = WireframeBackgroundColor;
        wireframeCam.targetTexture = wireframeRT;
        wireframeCam.SetReplacementShader(wireframeShader, string.Empty);

        Graphics.Blit(src, dest, compositeMat);
    }
}
