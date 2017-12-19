using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(ParticleSystem))]
public class TakenStreaks : MonoBehaviour
{
    public float MinStreakLength = 0.0f;
    public float MaxStreakLength = 0.15f;
    public float MinStreakWidth = 0.0f;
    public float MaxStreakWidth = 0.03f;

    public float MaxStreakLengthDistance = 3.0f;
    public float MinStreakLengthDistance = 8.0f;
    public float MaxStreakWidthDistance = 5.0f;
    public float MinStreakWidthDistance = 15.0f;

    private ParticleSystem system;

    void Start()
    {
        system = GetComponent<ParticleSystem>();
    }

    void Update()
    {
        float distance = Vector3.Distance(Camera.main.transform.position, transform.position);

        float lengthProgress = (distance - MinStreakLengthDistance) /
            (MaxStreakLengthDistance - MinStreakLengthDistance);
        float length = Mathf.Lerp(MinStreakLength, MaxStreakLength,
            Mathf.Clamp(lengthProgress, 0, 1));

        float widthProgress = (distance - MinStreakWidthDistance) /
            (MaxStreakWidthDistance - MinStreakWidthDistance);
        float width = Mathf.Lerp(MinStreakWidth, MaxStreakWidth,
            Mathf.Clamp(widthProgress, 0, 1));

        var main = system.main;
        main.startSizeY = new ParticleSystem.MinMaxCurve(length);
        main.startSizeX = new ParticleSystem.MinMaxCurve(width);
        main.startSizeZ = new ParticleSystem.MinMaxCurve(width);

        system.Simulate(0.5f);
    }
}
