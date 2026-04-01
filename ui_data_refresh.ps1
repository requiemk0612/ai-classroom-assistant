$root = "D:\Projects\ai-classroom-assistant"
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)

function Write-Utf8NoBom {
  param(
    [string]$Path,
    [string]$Content
  )

  [System.IO.File]::WriteAllText($Path, $Content, $utf8NoBom)
}

Write-Utf8NoBom "$root\data\strategy-library.json" @'
{
  "topics": [
    {
      "topicId": "multivar_total_derivative",
      "topicName": "全微分",
      "analogy": [
        "可以把全微分理解成函数在当前点附近的线性近似，用一个最贴近曲面的平面来估计函数增量。",
        "如果把函数值变化想成爬山时海拔变化，那么全微分就是脚下这一小步里海拔变化的快速估计。"
      ],
      "visual": [
        "展示曲面和切平面的叠加图，突出邻域内二者非常接近。",
        "用不同颜色标出 dx 和 dy 对函数值变化的贡献，再合成总变化。"
      ],
      "quickCheck": [
        "让学生判断 dz = fx dx + fy dy 中哪一项代表 y 方向带来的变化。",
        "用一道匿名判断题确认学生是否理解“可微”和“存在全微分”的关系。"
      ],
      "keyPoints": [
        "全微分描述函数增量的线性主部。",
        "二元函数可微时可写成 dz = fx dx + fy dy。",
        "全微分与切平面和局部线性近似密切相关。"
      ]
    },
    {
      "topicId": "directional_derivative",
      "topicName": "方向导数",
      "analogy": [
        "方向导数就像站在山坡上一点，沿着你选定的方向迈出一步时海拔变化的快慢。",
        "偏导数只是方向导数在坐标轴方向上的特殊情形。"
      ],
      "visual": [
        "在等高线图上画出一点和一个单位方向向量，说明沿该方向函数值如何变化。",
        "用箭头比较不同方向上的变化率，让学生看到为什么方向不同结果会不同。"
      ],
      "quickCheck": [
        "做一道匿名选择题，确认学生是否知道方向向量需要先单位化。",
        "让学生快速判断偏导数是不是某个特定方向的方向导数。"
      ],
      "keyPoints": [
        "方向导数描述函数沿指定方向的变化率。",
        "计算时要使用单位方向向量。",
        "当函数可微时，方向导数可由梯度与单位方向向量的点积给出。"
      ]
    },
    {
      "topicId": "gradient",
      "topicName": "梯度",
      "analogy": [
        "梯度就像山坡上“上升最快”的箭头，指向函数值增长最快的方向。",
        "如果方向导数回答“沿这个方向上升多快”，梯度回答的就是“往哪里走上升最快”。"
      ],
      "visual": [
        "在等高线图上画出梯度向量，并强调它与等高线正交。",
        "用不同方向的方向导数柱状比较图，突出梯度方向取得最大值。"
      ],
      "quickCheck": [
        "发起一个匿名判断题：梯度模长是否等于最大方向导数。",
        "让学生快速回答梯度方向与等高线的关系。"
      ],
      "keyPoints": [
        "梯度由各个偏导数组成。",
        "梯度方向是函数增长最快的方向。",
        "梯度的模等于最大方向导数。",
        "梯度与等高线或等值面正交。"
      ]
    },
    {
      "topicId": "tangent_plane",
      "topicName": "切平面与法向量",
      "analogy": [
        "切平面像是在曲面上轻轻放上一块最贴合的小平板。",
        "法向量像是竖直插在切平面上的小旗杆，用来确定平面的方向。"
      ],
      "visual": [
        "展示曲面、切点、切平面和法向量的组合图。",
        "用三维图说明偏导数如何决定切平面的倾斜程度。"
      ],
      "quickCheck": [
        "让学生判断切平面方程中常数项来自哪个切点。",
        "做一道匿名题确认学生是否知道隐函数情形下梯度常给出法向量。"
      ],
      "keyPoints": [
        "切平面是曲面在一点处的线性近似。",
        "法向量可以帮助快速写出切平面方程。",
        "在隐函数情形下，梯度常与法向量方向一致。"
      ]
    }
  ]
}
'@

Write-Utf8NoBom "$root\data\course-materials.json" @'
{
  "chunks": [
    {
      "chunkId": "chunk_001",
      "topicId": "multivar_total_derivative",
      "title": "全微分的定义",
      "content": "对于二元函数 z = f(x, y)，如果函数增量可以写成 dz = fx dx + fy dy 加上高阶无穷小，那么这个线性主部就叫作全微分。",
      "sourceName": "高等数学讲义 第七章 多元函数微分学",
      "page": "P12",
      "keywords": ["全微分", "可微", "线性主部", "dz"]
    },
    {
      "chunkId": "chunk_002",
      "topicId": "multivar_total_derivative",
      "title": "全微分的几何意义",
      "content": "全微分反映了函数在一点附近的局部线性近似。对曲面 z = f(x, y) 来说，可以把切平面的变化看成函数变化的近似描述。",
      "sourceName": "高等数学讲义 第七章 多元函数微分学",
      "page": "P13",
      "keywords": ["几何意义", "切平面", "局部线性近似"]
    },
    {
      "chunkId": "chunk_003",
      "topicId": "directional_derivative",
      "title": "方向导数的定义",
      "content": "方向导数描述函数沿某个指定方向的变化率。计算时方向向量需要先单位化，然后再考察沿该方向的极限变化。",
      "sourceName": "高等数学讲义 第七章 多元函数微分学",
      "page": "P18",
      "keywords": ["方向导数", "单位方向向量", "变化率"]
    },
    {
      "chunkId": "chunk_004",
      "topicId": "directional_derivative",
      "title": "方向导数与梯度的关系",
      "content": "如果函数在某点可微，那么沿单位方向向量 u 的方向导数等于 grad f 与 u 的点积。方向不同，方向导数也会不同。",
      "sourceName": "高等数学讲义 第七章 多元函数微分学",
      "page": "P19",
      "keywords": ["方向导数", "梯度", "点积", "可微"]
    },
    {
      "chunkId": "chunk_005",
      "topicId": "gradient",
      "title": "梯度的定义",
      "content": "梯度是由各个偏导数组成的向量。它既表示变化快慢，也给出了函数值增长最快的方向信息。",
      "sourceName": "高等数学讲义 第七章 多元函数微分学",
      "page": "P20",
      "keywords": ["梯度", "偏导数", "向量", "grad"]
    },
    {
      "chunkId": "chunk_006",
      "topicId": "gradient",
      "title": "梯度的几何意义",
      "content": "在函数可微的条件下，梯度方向是函数值增长最快的方向，梯度的模等于该点的最大方向导数。在二维情形下，梯度向量与等高线正交。",
      "sourceName": "高等数学讲义 第七章 多元函数微分学",
      "page": "P21",
      "keywords": ["几何意义", "最大方向导数", "等高线", "正交"]
    },
    {
      "chunkId": "chunk_007",
      "topicId": "tangent_plane",
      "title": "切平面方程",
      "content": "若曲面 z = f(x, y) 在切点处可微，那么切平面方程可以写成 z - z0 = fx(x0, y0)(x - x0) + fy(x0, y0)(y - y0)。",
      "sourceName": "高等数学讲义 第七章 多元函数微分学",
      "page": "P15",
      "keywords": ["切平面", "方程", "可微", "偏导数"]
    },
    {
      "chunkId": "chunk_008",
      "topicId": "gradient",
      "title": "最大方向导数结论",
      "content": "当单位方向向量与梯度向量同向时，方向导数取得最大值，这个最大值等于梯度的模。因此要求函数增长最快的方向，只需要求出梯度。",
      "sourceName": "高等数学讲义 第七章 多元函数微分学",
      "page": "P22",
      "keywords": ["最大方向导数", "梯度模", "增长最快", "同向"]
    }
  ]
}
'@

Write-Utf8NoBom "$root\data\pressure-data.json" @'
{
  "sessionId": "demo_session_001",
  "homeworkSpeed": 0.58,
  "accuracyRate": 0.71,
  "moodWords": ["有点吃力", "公式偏多", "图像有帮助", "需要例题", "推导有点快"],
  "weeklyTrend": [0.34, 0.39, 0.48, 0.55, 0.62],
  "simplificationPack": {
    "title": "知识简化包：方向导数与梯度",
    "summary": "建议先把方向导数理解成沿指定方向的变化率，再把梯度理解成变化最快方向的向量指示器，最后用点积关系把二者连起来。",
    "actions": [
      "先复习偏导数的几何意义，再看方向导数定义。",
      "把单位方向向量代入公式，单独练习两个方向导数例题。",
      "通过等高线图理解梯度与最大方向导数的关系。"
    ]
  }
}
'@

Write-Utf8NoBom "$root\data\mindmap-data.json" @'
{
  "topicId": "gradient",
  "courseName": "高等数学：全微分、方向导数与梯度",
  "summaryPoints": [
    "全微分描述函数增量的线性主部。",
    "方向导数表示函数沿指定方向的变化率。",
    "计算方向导数时要先确定单位方向向量。",
    "梯度由各个偏导数组成，并指向增长最快的方向。",
    "梯度的模等于最大方向导数。",
    "梯度与等高线或等值面正交。"
  ],
  "nodes": [
    {
      "id": "root",
      "data": {
        "label": "高等数学：全微分、方向导数与梯度"
      },
      "position": {
        "x": 420,
        "y": 40
      }
    },
    {
      "id": "node_1",
      "data": {
        "label": "全微分"
      },
      "position": {
        "x": 120,
        "y": 200
      }
    },
    {
      "id": "node_2",
      "data": {
        "label": "方向导数"
      },
      "position": {
        "x": 300,
        "y": 200
      }
    },
    {
      "id": "node_3",
      "data": {
        "label": "单位方向向量"
      },
      "position": {
        "x": 480,
        "y": 200
      }
    },
    {
      "id": "node_4",
      "data": {
        "label": "梯度"
      },
      "position": {
        "x": 660,
        "y": 200
      }
    },
    {
      "id": "node_5",
      "data": {
        "label": "最大方向导数"
      },
      "position": {
        "x": 840,
        "y": 200
      }
    },
    {
      "id": "node_6",
      "data": {
        "label": "等高线正交"
      },
      "position": {
        "x": 1020,
        "y": 200
      }
    }
  ],
  "edges": [
    {
      "id": "edge_1",
      "source": "root",
      "target": "node_1"
    },
    {
      "id": "edge_2",
      "source": "root",
      "target": "node_2"
    },
    {
      "id": "edge_3",
      "source": "root",
      "target": "node_3"
    },
    {
      "id": "edge_4",
      "source": "root",
      "target": "node_4"
    },
    {
      "id": "edge_5",
      "source": "root",
      "target": "node_5"
    },
    {
      "id": "edge_6",
      "source": "root",
      "target": "node_6"
    }
  ],
  "sourceSlides": [
    "第1页：多元函数微分学概览",
    "第2页：全微分的定义与几何意义",
    "第3页：方向导数的定义",
    "第4页：梯度与最大方向导数",
    "第5页：梯度与等高线的关系"
  ],
  "updatedAt": "2026-04-01T03:55:55.690Z"
}
'@
