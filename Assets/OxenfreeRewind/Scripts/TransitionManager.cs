using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class TransitionManager : MonoBehaviour
{
    private static TransitionManager instance = null;
    public static TransitionManager Instance
    {
        get { return instance; }
    }

    private string targetScene;
    private AsyncOperation loadScene;

    void Awake()
    {
        // ensure we only have one instance of this object
        if (instance != null && instance != this)
        {
            Destroy(this.gameObject);
            return;
        }
        else
        {
            instance = this;
        }
        DontDestroyOnLoad(this.gameObject);
    }

    void Update()
    {
        // has the destination scene been loaded?
        if (loadScene != null && loadScene.isDone)
        {
            loadScene = null;

            // finish rewind animation
            var rewind = Camera.main.GetComponent<OxenfreeRewindEffect>();
            if (rewind != null)
            {
                rewind.FinishRewind();
            }
        }
    }

    public void Navigate(string sceneName)
    {
        targetScene = sceneName;
        StartCoroutine(LoadScene());
    }

    IEnumerator LoadScene()
    {
        loadScene = SceneManager.LoadSceneAsync(targetScene);
        yield return loadScene;
    }
}