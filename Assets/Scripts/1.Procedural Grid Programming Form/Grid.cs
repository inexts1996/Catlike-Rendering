using System.Collections;
using UnityEngine;

[RequireComponent(typeof(MeshFilter), typeof(MeshRenderer))]
public class Grid : MonoBehaviour
{
    public int xSize, ySize;

    void Awake()
    {
        Generate();
    }
    // Start is called before the first frame update
    void Start()
    {
    }

    private Vector3[] vertices;
    private Mesh mesh;
    private void Generate()
    {
        GetComponent<MeshFilter>().mesh = mesh = new Mesh();
        mesh.name = "Procedural Grid";

        vertices = new Vector3[(xSize + 1) * (ySize + 1)];
        Vector2[] uv = new Vector2[vertices.Length];
        Vector4[] tangents = new Vector4[vertices.Length];
        Vector4 tangent = new Vector4(1, 0, 0, -1);

        for (int i = 0, y = 0; y <= ySize; y++)
        {
            for (int x = 0; x <= xSize; x++, i++)
            {
                vertices[i] = new Vector3(x, y);
                uv[i] = new Vector2(x * 1f / xSize, y * 1f / ySize);
                tangents[i] = tangent;
            }
        }

        mesh.vertices = vertices;
        mesh.uv = uv;
        mesh.tangents = tangents;

        int[] triangles = new int[ySize * xSize * 6];
        for (int ti = 0, vi = 0, y = 0; y < ySize; y++, vi++)
        {
            for (int x = 0; x < xSize; ti += 6, vi++, x++)
            {
                triangles[ti] = vi;
                triangles[ti + 1] = triangles[ti + 4] = vi + xSize + 1;
                triangles[ti + 2] = triangles[ti + 3] = vi + 1;
                triangles[ti + 5] = vi + xSize + 2;
            }
        }

        mesh.triangles = triangles;
        mesh.RecalculateNormals();
    }

    // Update is called once per frame
    void Update()
    {

    }

    private void OnDrawGizmos()
    {
        if (vertices == null) return;
        Gizmos.color = Color.black;

        for (int i = 0; i < vertices.Length; i++)
        {
            Gizmos.DrawSphere(vertices[i], 0.1f);
        }
    }
}
