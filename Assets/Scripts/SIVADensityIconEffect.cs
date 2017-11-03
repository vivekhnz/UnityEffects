using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

[RequireComponent(typeof(Image))]
public class SIVADensityIconEffect : MonoBehaviour
{
    public float JitterDurationSeconds = 0.1f;
    public float JitterDelaySeconds = 4f;

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
}
