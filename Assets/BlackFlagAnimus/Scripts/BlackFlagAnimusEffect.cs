using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BlackFlagAnimusEffect : MonoBehaviour
{
    private Material effectMat;

    /// <summary>
    /// Start is called on the frame when a script is enabled just before
    /// any of the Update methods is called the first time.
    /// </summary>
    void Start()
    {
        // create shader material
        var shader = Shader.Find("Custom/BlackFlagAnimus");
        effectMat = new Material(shader);
    }

    /// <summary>
    /// OnRenderImage is called after all rendering is complete to render image.
    /// </summary>
    /// <param name="src">The source RenderTexture.</param>
    /// <param name="dest">The destination RenderTexture.</param>
    void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        Graphics.Blit(src, dest, effectMat);
    }
}
