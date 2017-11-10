using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

[RequireComponent(typeof(Image))]
public class SIVADensityIconEffect : MonoBehaviour
{
    private static readonly int DISTORTION_PATTERN_STEPS = 44;

    public float JitterDurationSeconds = 0.1f;
    public float JitterDelaySeconds = 4f;
    public float DistortionAmplitude = 0.15f;
    public float Opacity = 0.075f;
    public float DistortionPatternDurationSeconds = 10.0f;

    private Material material;

    /// <summary>
    /// Start is called on the frame when a script is enabled just before
    /// any of the Update methods is called the first time.
    /// </summary>
    void Start()
    {
        material = GetComponent<Image>().material;
    }

    /// <summary>
    /// Update is called every frame, if the MonoBehaviour is enabled.
    /// </summary>
    void Update()
    {
        material.SetFloat("_HorizontalOffset", CalculateHorizontalOffset());
        material.SetFloat("_DistortionAmplitude", CalculateDistortion() * DistortionAmplitude);
        material.SetFloat("_Opacity", CalculateOpacity() * Opacity);
    }

    private float CalculateHorizontalOffset()
    {
        // calculate current progress through the pattern
        float totalLength = JitterDurationSeconds + JitterDelaySeconds;
        float patternLength = 7 + ((7 / JitterDurationSeconds) * JitterDelaySeconds);
        float t = ((Time.time % totalLength) / totalLength) * patternLength;

        if (t < 6)
        {
            // calculate animation
            return (Mathf.Cos((Mathf.PI * (t + 2)) / 2) + 1) / 2;
        }
        else
        {
            // snap to right
            return 0;
        }
    }

    private float CalculateDistortion()
    {
        // calculate current progress through the pattern
        float t = (Time.time * (DISTORTION_PATTERN_STEPS / DistortionPatternDurationSeconds)) %
            DISTORTION_PATTERN_STEPS;

        float distortion = 0;
        if (t < 12)
        {
            distortion = Mathf.Sin((Mathf.PI * t) / 4);
        }
        else if (t > 16 && t < 18)
        {
            distortion = Mathf.Sin((Mathf.PI * t) / 2);
        }
        else if (t > 26 && t < 32)
        {
            distortion = -Mathf.Sin((Mathf.PI * t) / 2);
        }
        else if (t > 34)
        {
            distortion = Mathf.Sin((Mathf.PI * (t - 4)) / 5);
        }
        else
        {
            return 0;
        }
        return Mathf.Max(Mathf.Pow(distortion, 3), 0);
    }

    private float CalculateOpacity()
    {
        // calculate current progress through the pattern
        float t = (Time.time * (DISTORTION_PATTERN_STEPS / DistortionPatternDurationSeconds)) %
            DISTORTION_PATTERN_STEPS;

        if ((t > 34 && t < 35) || t > 43)
        {
            return 0;
        }
        return 1;
    }
}
