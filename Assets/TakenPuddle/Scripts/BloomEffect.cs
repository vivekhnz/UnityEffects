using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BloomEffect : MonoBehaviour
{
    public string GlowLayerName = "Glow";
    [Range(1, 8)]
    public int DownresFactor = 1;

    private Camera attachedCamera;
    private Camera depthCam;
    private Camera blurCam;
    private int glowOnlyLayerMask;

    private RenderTexture depthRT;
    private RenderTexture blurRT;
    private Material compositeMaterial;

    private float intensity;

    /// <summary>
    /// Start is called on the frame when a script is enabled just before
    /// any of the Update methods is called the first time.
    /// </summary>
    void Start()
    {
        attachedCamera = GetComponent<Camera>();

        // create render texture to store depth and blurred textures in
        depthRT = new RenderTexture(Screen.width, Screen.height, 0, RenderTextureFormat.ARGBFloat);
        blurRT = new RenderTexture(Screen.width >> DownresFactor,
            Screen.height >> DownresFactor, 0);
        glowOnlyLayerMask = 1 << LayerMask.NameToLayer(GlowLayerName);

        // add a temporary camera that only renders the glowing objects
        // the depth is stored in the alpha channel
        depthCam = new GameObject().AddComponent<Camera>();
        depthCam.name = "Depth Camera (Bloom)";

        // add a temporary camera to render the blurred scene
        // the blur effect also masks glowing objects based on depth
        blurCam = new GameObject().AddComponent<Camera>();
        blurCam.name = "Blur Camera (Bloom)";
        var blur = blurCam.gameObject.AddComponent<BlurEffect>();
        blur.BlurSize = new Vector2(blurRT.texelSize.x * 1.5f, blurRT.texelSize.y * 1.5f);
        blur.DepthTexture = depthRT;

        // create shader material to composite the final image
        var compositeShader = Shader.Find("Custom/Bloom/Composite");
        compositeMaterial = new Material(compositeShader);
        compositeMaterial.SetTexture("_BlurredTex", blurRT);
    }

    /// <summary>
    /// LateUpdate is called every frame, if the Behaviour is enabled.
    /// It is called after all Update functions have been called.
    /// </summary>
    void LateUpdate()
    {
        // update intensity in late update to ensure the maximum intensity value is retrieved
        compositeMaterial.SetFloat("_Intensity", intensity);
        intensity = 0;
    }

    /// <summary>
    /// OnRenderImage is called after all rendering is complete to render image.
    /// </summary>
    /// <param name="src">The source RenderTexture.</param>
    /// <param name="dest">The destination RenderTexture.</param>
    void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        // ensure temporary cameras are synchronized with main camera
        depthCam.CopyFrom(attachedCamera);
        depthCam.backgroundColor = Color.black;
        depthCam.cullingMask = glowOnlyLayerMask;
        depthCam.targetTexture = depthRT;

        blurCam.CopyFrom(attachedCamera);
        blurCam.backgroundColor = Color.black;
        blurCam.targetTexture = blurRT;

        // composite final image
        Graphics.Blit(src, dest, compositeMaterial);
    }

    public void SetPerFrameIntensity(float intensity)
    {
        this.intensity = Mathf.Max(this.intensity, intensity);
    }
}
