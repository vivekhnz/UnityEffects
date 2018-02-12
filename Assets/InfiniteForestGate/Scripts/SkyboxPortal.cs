using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(Skybox))]
public class SkyboxPortal : MonoBehaviour
{
    public Material OuterSkybox;
    public Material InnerSkybox;
    public string PortalLayerName = "Portal";

    private Camera attachedCamera;
    private Skybox attachedSkybox;

    private Camera portalCam;
    private Skybox portalSkybox;
    private RenderTexture portalRT;
    private int portalOnlyMask;

    void Start()
    {
        attachedCamera = GetComponent<Camera>();
        attachedSkybox = GetComponent<Skybox>();
        attachedSkybox.material = OuterSkybox;

        // create render texture to store the portal texture in
        portalRT = new RenderTexture(Screen.width, Screen.height, 0);
        Shader.SetGlobalTexture("_PortalSkyboxTexture", portalRT);

        // add a temporary camera that renders the 'portal' scene
        portalCam = new GameObject().AddComponent<Camera>();
        portalCam.name = "Portal Camera";
        portalSkybox = portalCam.gameObject.AddComponent<Skybox>();
        portalSkybox.material = InnerSkybox;

        // create culling masks to exclude portal
        portalOnlyMask = 1 << LayerMask.NameToLayer(PortalLayerName);
        attachedCamera.cullingMask = ~portalOnlyMask;
    }

    /// <summary>
    /// OnRenderImage is called after all rendering is complete to render image.
    /// </summary>
    /// <param name="src">The source RenderTexture.</param>
    /// <param name="dest">The destination RenderTexture.</param>
    void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        portalCam.CopyFrom(attachedCamera);
        portalCam.targetTexture = portalRT;
        portalCam.cullingMask = portalOnlyMask;

        Graphics.Blit(src, dest);
    }
}
