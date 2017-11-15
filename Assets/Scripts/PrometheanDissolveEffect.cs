using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PrometheanDissolveEffect : MonoBehaviour
{
    public float DissolveUnitsPerSecond = 1;

    private Material material;

    void Start()
    {
        material = GetComponent<MeshRenderer>().material;
    }

    void Update()
    {
        material.SetFloat("_DissolveRadius", Time.time * DissolveUnitsPerSecond);
    }
}
