using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ComputeRippleGenerater : MonoBehaviour
{
    public ComputeShader waveComputer;
    public Material mat;

    private int texW,texH;
    private RenderTexture r1;
    private RenderTexture r2;
    private int k;
    // Start is called before the first frame update
    private bool ifResult1 = true;
    void Start()
    {
        texW = Screen.width;
        texH = Screen.height;
        r1 = new RenderTexture(texW, texH, 24);
        r1.enableRandomWrite = true;
        r1.Create();
        r2 = new RenderTexture(texW, texH, 24);
        r2.enableRandomWrite = true;
        r2.Create();
        k = waveComputer.FindKernel("CSMain");
    }

    // Update is called once per frame
    void Update()
    {
        if(true)
        {
            if (true)
            {
                int[] posI = { -100, -100 };
                if (Input.GetMouseButtonDown(0))
                {
                    posI[0] = (int)(Input.mousePosition.x);
                    posI[1] = (int)(Input.mousePosition.y);
                }
                if (ifResult1)
                {
                    waveComputer.SetTexture(k, "Result", r1);
                    waveComputer.SetTexture(k, "buffer", r2);
                    mat.SetTexture("_RealMainTex", r1);
                }
                else
                {
                    waveComputer.SetTexture(k, "Result", r2);
                    waveComputer.SetTexture(k, "buffer", r1);
                    mat.SetTexture("_RealMainTex", r2);
                }
                waveComputer.SetInts("mousePos", posI);
                k = waveComputer.FindKernel("CSMain");
                waveComputer.Dispatch(k, texW / 8, texH / 8, 1);
                ifResult1 = !ifResult1;
            }
        }

    }
}
