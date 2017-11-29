using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class DissolveCursor : MonoBehaviour
{
    public Color IdleCursorColor = Color.green;
    public Color DetectedCursorColor = Color.red;
    public PrometheanDissolveEffect DissolveSource;

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
        // determine what the reticle is pointed at
        Transform camera = Camera.main.transform;
        RaycastHit hit;
        Transform target = null;
        if (Physics.Raycast(camera.position, camera.forward, out hit))
        {
            var transform = hit.transform;
            if (transform.CompareTag("Dissolvable"))
            {
                target = transform;
            }
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
        if (target != null && Input.GetButtonDown("Fire1"))
        {
            // ensure the target is not already dissolving
            if (target.GetComponentInChildren<PrometheanDissolveEffect>() == null)
            {
                var source = Instantiate(DissolveSource);
                var animator = target.GetComponentInParent<Animator>();
                if (animator != null)
                {
                    animator.SetTrigger("OnKilled");
                }
                source.DissolveTarget(target, hit.point);
            }
        }

        wasDetected = detected;
    }
}
