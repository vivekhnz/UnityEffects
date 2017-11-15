using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class DissolveCursor : MonoBehaviour
{
    public Color IdleCursorColor = Color.green;
    public Color DetectedCursorColor = Color.red;

    private Image[] crosshairImages;
    private bool wasDetected;

    void Start()
    {
        crosshairImages = GetComponentsInChildren<Image>();
        wasDetected = false;

        foreach (var image in crosshairImages)
        {
            image.color = IdleCursorColor;
        }
    }

    void Update()
    {
        RaycastHit hit;
        PrometheanDissolveEffect target = null;
        if (Physics.Raycast(Camera.main.transform.position, Camera.main.transform.forward, out hit))
        {
            var transform = hit.transform;
            target = transform.GetComponent<PrometheanDissolveEffect>();
        }

        // update crosshair colour
        bool detected = target != null;
        if (detected != wasDetected)
        {
            foreach (var image in crosshairImages)
            {
                image.color = detected ? DetectedCursorColor : IdleCursorColor;
            }
        }

        // dissolve target
        if (target != null && Input.GetAxis("Fire1") > 0)
        {
            target.DissolveFrom(hit.point);
        }

        wasDetected = detected;
    }
}
