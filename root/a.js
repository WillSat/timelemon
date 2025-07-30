const timeline = document.getElementById('timeline');
const tooltip = document.getElementById('tooltip');

// 设置当前日期
const now = new Date();
document.getElementById('currentDate').textContent =
    `${now.getFullYear()} 年 ${now.getMonth() + 1} 月 ${now.getDate()} 日`;

// 颜色映射
const colors = {
    '政治': '#FFCCBC',
    '经济': '#FFE0B2',
    '社会民生': '#F0F4C3',
    '公共安全': '#B2DFDB',
    '文化': '#BBDEFB',
    '科技': '#C5CAE9',
    '其他': '#CFD8DC',
    'important': '#00B0FF',
    'urgent': '#FF9100',
    'critical': '#FF3D00',
};

const priority = {
    'important': 1,
    'urgent': 2,
    'critical': 3,
    '政治': 1,
    '经济': 2,
    '社会民生': 3,
    '公共安全': 4,
    '文化': 5,
    '科技': 6,
    '其他': 7,
};

const oneDayKeywords = { 1: [], 2: [], 3: [], 4: [] };

const todayDate = now.getFullYear()
    + ('0' + (now.getMonth() + 1)).slice(-2)
    + ('0' + now.getDate()).slice(-2);

for (const quarterDayNum of [1, 2, 3, 4]) {
    // 从后端获取数据
    try {
        fetch(`jsondata/${todayDate}-${quarterDayNum}.json`)
            .then(r => r.json())
            .then(quarterDayWordsList => {
                oneDayKeywords[quarterDayNum] = quarterDayWordsList.sort((a, b) => {
                    if (priority[a.sign] < priority[b.sign]) return true;
                    if (priority[a.sign] > priority[b.sign]) return false;
                    if (priority[a.sign] = priority[b.sign]) return priority[a.kind] > priority[b.kind];
                });
                randerQuarterDay(quarterDayNum);
            });
    } catch (error) {
        console.log(`File ${todayDate}-${quarterDayNum} doesn't exist!`);
    }
}

// 渲染时间线
function randerQuarterDay(quarterDayNum) {
    const hourBlock = document.getElementById(`quarterday${quarterDayNum}`);

    oneDayKeywords[quarterDayNum].forEach(keyword => {
        const keywordItem = document.createElement('div');
        keywordItem.className = 'keyword-item';
        keywordItem.textContent = keyword.word;
        keywordItem.style.backgroundColor = colors[keyword.kind];

        // 根据重要性设置文字颜色
        if (keyword.sign === 'critical') {
            keywordItem.style.fontWeight = 'bold';
        }

        keywordItem.style.borderLeft = `6px solid ${colors[keyword.sign]}`;

        // 鼠标事件
        keywordItem.addEventListener('pointermove', (e) => {
            tooltip.style.display = 'block';
            tooltip.style.left = `${e.pageX + 10}px`;
            tooltip.style.top = `${e.pageY + 10}px`;
            tooltip.innerHTML = `<strong>${keyword.word}</strong><br>${keyword.desc}<br><em>${keyword.sign === 'critical' ? '关键' : keyword.sign === 'urgent' ? '紧急' : '重要'}</em> · <em>${keyword.kind}</em>`;
        });

        keywordItem.addEventListener('pointerleave', () => {
            tooltip.style.display = 'none';
        });

        hourBlock.appendChild(keywordItem);
    });

    // 如果没有关键词，显示提示
    if (oneDayKeywords[quarterDayNum].length === 0) {
        const emptyMsg = document.createElement('div');
        emptyMsg.classList.add('keyword-item');
        emptyMsg.classList.add('empty');
        emptyMsg.textContent = 'Nothing happened?';
        emptyMsg.style.color = '#999';
        emptyMsg.style.fontStyle = 'italic';
        hourBlock.appendChild(emptyMsg);
    }

    timeline.appendChild(hourBlock);
}