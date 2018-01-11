using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BlackFlagAnimusEffect : MonoBehaviour
{
    public Color WireframeBackgroundColor = Color.black;
    public Color WireframeLineColor = Color.white;

    [Range(0, 1)]
    public float WireframeScanProgress = 0;
    [Range(0, 1)]
    public float SceneScanProgress = 0;
    [Range(0, 1)]
    public float ScanLineOpacity = 0.1f;
    [Range(0, 1)]
    public float WipeAlpha = 0;
    [Range(0, 1)]
    public float FogAlpha = 0;
    public bool RenderSkybox = false;
    public bool IsEffectEnabled = false;
    public bool IsTransitioningOut = false;

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
        Shader.SetGlobalColor("_WireframeLineColor", WireframeLineColor);
        Shader.SetGlobalFloat("_ScanFringeWidth", 0.1f);

        // create shader material
        var compositeShader = Shader.Find("Custom/BlackFlagAnimus/Composite");
        compositeMat = new Material(compositeShader);
        compositeMat.SetTexture("_WireframeTex", wireframeRT);
        compositeMat.SetColor("_BackgroundColor", WireframeBackgroundColor);
    }

    /// <summary>
    /// Update is called every frame, if the MonoBehaviour is enabled.
    /// </summary>
    void Update()
    {
        Shader.SetGlobalFloat("_WireframeScanProgress", WireframeScanProgress);
        Shader.SetGlobalColor("_WireframeBackgroundColor", WireframeBackgroundColor);

        compositeMat.SetFloat("_ScanProgress", SceneScanProgress);
        compositeMat.SetFloat("_ScanLineOpacity", ScanLineOpacity);
        compositeMat.SetFloat("_WipeAlpha", WipeAlpha);
        compositeMat.SetFloat("_FogAlpha", FogAlpha);
        compositeMat.SetColor("_FogColor", WireframeLineColor);

        attachedCamera.clearFlags = RenderSkybox ? CameraClearFlags.Skybox :
            CameraClearFlags.SolidColor;
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

        if (IsEffectEnabled)
        {
            Graphics.Blit(src, dest, compositeMat, IsTransitioningOut ? 1 : 0);
        }
        else
        {
            Graphics.Blit(src, dest);
        }
    }
}
