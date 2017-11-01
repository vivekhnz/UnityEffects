using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SIVADensityEffect : MonoBehaviour
{
    public Material EffectMaterial;
    public float StaticIntensity = 0.25f;

    /// <summary>
    /// Update is called every frame, if the MonoBehaviour is enabled.
    /// </summary>
    void Update()
    {
        float t = (Time.time * 8) % 24;
        float intensity = 0;
        if (t < 4 || t > 6 && t < 8)
        {
            intensity = (Mathf.Sin(Mathf.PI * (t - 0.5f)) / 2) + 0.5f;
        }
        else if (t > 14 && t < 17)
        {
            intensity = Mathf.Sin((Mathf.PI / 3) * (t + 4));
        }

        EffectMaterial.SetFloat("_StaticIntensity", intensity * StaticIntensity);
    }

    /// <summary>
    /// OnRenderImage is called after all rendering is complete to render image.
    /// </summary>
    /// <param name="src">The source RenderTexture.</param>
    /// <param name="dest">The destination RenderTexture.</param>
    void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        Graphics.Blit(src, dest, EffectMaterial);
    }
}
