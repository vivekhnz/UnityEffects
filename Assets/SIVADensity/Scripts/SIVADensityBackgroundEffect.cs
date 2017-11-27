using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SIVADensityBackgroundEffect : MonoBehaviour
{
    private static readonly int STATIC_PATTERN_STEPS = 24;

    public Material EffectMaterial;
    public float StaticIntensity = 0.25f;
    public float StaticPatternDurationSeconds = 3f;

    [Range(1, 64)]
    public int NoiseUnitSize = 4;

    /// <summary>
    /// Update is called every frame, if the MonoBehaviour is enabled.
    /// </summary>
    void Update()
    {
        EffectMaterial.SetTexture("_Noise", GenerateNoiseTexture(
            Camera.main.pixelWidth / NoiseUnitSize, Camera.main.pixelHeight / NoiseUnitSize));
        EffectMaterial.SetFloat("_StaticIntensity", CalculateStaticIntensity() * StaticIntensity);
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

    private Texture GenerateNoiseTexture(int width, int height)
    {
        Texture2D texture = new Texture2D(width, height, TextureFormat.Alpha8, false);
        for (int y = 0; y < height; y++)
        {
            for (int x = 0; x < width; x++)
            {
                texture.SetPixel(x, y, new Color(0, 0, 0, Random.Range(0f, 1f)));
            }
        }
        texture.Apply();
        return texture;
    }

    private float CalculateStaticIntensity()
    {
        // calculate current progress through the pattern
        float t = (Time.time * (STATIC_PATTERN_STEPS / StaticPatternDurationSeconds)) %
            STATIC_PATTERN_STEPS;

        if (t < 4 || t > 6 && t < 8)
        {
            // calculate the first 3 pulses
            return (Mathf.Sin(Mathf.PI * (t - 0.5f)) / 2) + 0.5f;
        }
        else if (t > 14 && t < 17)
        {
            // calculate the final long pulse
            return Mathf.Sin((Mathf.PI / 3) * (t + 4));
        }
        return 0;
    }
}
