using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BloomEffect : MonoBehaviour
{
    public string GlowLayerName = "Glow";
    public Shader BlurShader;
    public Shader CompositeShader;
    [Range(1, 8)]
    public int DownresFactor = 1;

    private Camera attachedCamera;
    private Camera tempCam;
    private int mask;

    private Material compositeMaterial;
    private RenderTexture blurRT;

    /// <summary>
    /// Start is called on the frame when a script is enabled just before
    /// any of the Update methods is called the first time.
    /// </summary>
    void Start()
    {
        attachedCamera = GetComponent<Camera>();

        // create render texture to store blurred texture in
        blurRT = new RenderTexture(Screen.width >> DownresFactor,
            Screen.height >> DownresFactor, 0);

        // create shader material to composite the final image
        compositeMaterial = new Material(CompositeShader);
        compositeMaterial.SetTexture("_BlurredTex", blurRT);

        // add a temporary camera to render the blurred scene
        tempCam = new GameObject().AddComponent<Camera>();
        mask = 1 << LayerMask.NameToLayer(GlowLayerName);

        // set up the blur effect
        var blur = tempCam.gameObject.AddComponent<BlurEffect>();
        blur.BlurShader = BlurShader;
        blur.BlurSize = new Vector2(blurRT.texelSize.x * 1.5f, blurRT.texelSize.y * 1.5f);
    }

    /// <summary>
    /// OnRenderImage is called after all rendering is complete to render image.
    /// </summary>
    /// <param name="src">The source RenderTexture.</param>
    /// <param name="dest">The destination RenderTexture.</param>
    void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        // ensure temporary camera is synchronized with main camera
        tempCam.CopyFrom(attachedCamera);
        tempCam.clearFlags = CameraClearFlags.Color;
        tempCam.backgroundColor = Color.black;
        tempCam.cullingMask = mask;
        tempCam.targetTexture = blurRT;

        // composite final image
        Graphics.Blit(src, dest, compositeMaterial);
    }
}
