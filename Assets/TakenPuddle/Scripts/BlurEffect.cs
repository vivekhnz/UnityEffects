using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BlurEffect : MonoBehaviour
{
    [Range(1, 64)]
    public int Iterations = 4;
    public Vector2 BlurSize;
    public Texture DepthTexture;

    private Material blurMaterial;

    /// <summary>
    /// Start is called on the frame when a script is enabled just before
    /// any of the Update methods is called the first time.
    /// </summary>
    void Start()
    {
        var shader = Shader.Find("Custom/Bloom/Blur");
        blurMaterial = new Material(shader);
        blurMaterial.SetVector("_BlurSize", BlurSize);
        blurMaterial.SetTexture("_DepthTex", DepthTexture);
    }

    /// <summary>
    /// OnRenderImage is called after all rendering is complete to render image.
    /// </summary>
    /// <param name="src">The source RenderTexture.</param>
    /// <param name="dest">The destination RenderTexture.</param>
    void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        // apply depth-based mask
        var masked = RenderTexture.GetTemporary(src.width, src.height);
        Graphics.Blit(src, masked, blurMaterial, 0);

        // apply blur
        for (int i = 0; i < Iterations; i++)
        {
            var rt = RenderTexture.GetTemporary(masked.width, masked.height);
            Graphics.Blit(masked, rt, blurMaterial, 1);
            Graphics.Blit(rt, masked, blurMaterial, 2);
            RenderTexture.ReleaseTemporary(rt);
        }

        // render resultant image
        Graphics.Blit(masked, dest);
        RenderTexture.ReleaseTemporary(masked);
    }
}
