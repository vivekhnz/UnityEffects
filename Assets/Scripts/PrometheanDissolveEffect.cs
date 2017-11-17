using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PrometheanDissolveEffect : MonoBehaviour
{
    public float DissolveUnitsPerSecond = 1;

    private Material material;
    private bool isDissolving;
    private float dissolveTime = 0;

    void Start()
    {
        material = GetComponent<MeshRenderer>().material;
        isDissolving = false;
    }

    void Update()
    {
        if (isDissolving)
        {
            float t = Time.time - dissolveTime;
            material.SetFloat("_DissolveRadius", t * DissolveUnitsPerSecond);
        }
        else
        {
            material.SetFloat("_DissolveRadius", 0);
        }
    }

    public void DissolveFrom(Vector3 origin)
    {
        dissolveTime = Time.time;
        isDissolving = true;

        material.SetVector("_DissolveOrigin", origin);
    }
}
