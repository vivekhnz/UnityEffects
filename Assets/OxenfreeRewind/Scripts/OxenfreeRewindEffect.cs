using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(Animator))]
public class OxenfreeRewindEffect : MonoBehaviour
{
    public Material EffectMaterial;
    public float TintIntensity = 0;
    public float WaveDisplacementIntensity = 0;
    public float JitterDisplacementIntensity = 0;
    public float StaticIntensity = 0;
    public float StaticOverlayIntensity = 0;
    public float WaveOffset = 0;
    public float ScreenOffset = 0;

    private Animator animator;
    private TransitionManager transitions;

    private string targetScene;

    /// <summary>
    /// Start is called on the frame when a script is enabled just before
    /// any of the Update methods is called the first time.
    /// </summary>
    void Start()
    {
        animator = GetComponent<Animator>();
        transitions = GameObject.FindObjectOfType<TransitionManager>();
    }

    /// <summary>
    /// Update is called every frame, if the MonoBehaviour is enabled.
    /// </summary>
    void Update()
    {
        EffectMaterial.SetFloat("_TintIntensity", TintIntensity);
        EffectMaterial.SetFloat("_WaveDisplacementIntensity", WaveDisplacementIntensity);
        EffectMaterial.SetFloat("_JitterDisplacementIntensity", JitterDisplacementIntensity);
        EffectMaterial.SetFloat("_StaticIntensity", StaticIntensity);
        EffectMaterial.SetFloat("_StaticOverlayIntensity", StaticOverlayIntensity);
        EffectMaterial.SetFloat("_WaveOffset", WaveOffset);
        EffectMaterial.SetFloat("_ScreenOffset", ScreenOffset);
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

    public void StartRewind(string targetScene)
    {
        // called from the source scene
        // start the rewind animation
        this.targetScene = targetScene;
        animator.SetTrigger("OnRewind");
    }

    void OnNavigationReady()
    {
        // called from the source scene
        // triggered when the rewind-out animation finishes
        transitions.Navigate(targetScene);
    }

    public void FinishRewind()
    {
        // called from the destination scene
        // finish the rewind animation
        animator.SetTrigger("OnFinishRewind");
    }

}
