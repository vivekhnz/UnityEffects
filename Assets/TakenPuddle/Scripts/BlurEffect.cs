using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BlurEffect : MonoBehaviour
{
    public Shader BlurShader;
    [Range(1, 64)]
    public int Iterations = 4;
    public Vector2 BlurSize;

    private Material blurMaterial;

    /// <summary>
    /// Start is called on the frame when a script is enabled just before
    /// any of the Update methods is called the first time.
    /// </summary>
    void Start()
    {
        blurMaterial = new Material(BlurShader);
        blurMaterial.SetVector("_BlurSize", BlurSize);
    }

    /// <summary>
    /// OnRenderImage is called after all rendering is complete to render image.
    /// </summary>
    /// <param name="src">The source RenderTexture.</param>
    /// <param name="dest">The destination RenderTexture.</param>
    void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        // apply blur
        for (int i = 0; i < Iterations; i++)
        {
            var rt = RenderTexture.GetTemporary(src.width, src.height);
            Graphics.Blit(src, rt, blurMaterial, 0);
            Graphics.Blit(rt, src, blurMaterial, 1);
            RenderTexture.ReleaseTemporary(rt);
        }

        // render resultant image
        Graphics.Blit(src, dest);
    }
}
