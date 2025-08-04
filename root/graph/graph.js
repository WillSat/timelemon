// nodes = [{ 
//     id: <String>, 
//     name: <Optional,String>, 
//     size: <Number>, 
//     backgroundColor: <String>, 
//     color: <String>, 
//     links: [<Other.id>] 
// }];

// Physics parameters
const physicsParams = {
    repulsion: 100000,
    maxRepulsionDistance2: 30000,
    linkDistance: 100,
    linkStrength: 0.4,
    friction: 0.1,
    centerStrength: 0.18,
    dragStrength: 1.2,
};

const isTouch = 'ontouchstart' in window;

const eventList = isTouch ? ['touchstart', 'touchmove', 'touchend', 'touchcancel'] : ['pointerdown', 'pointermove', 'pointerup', 'pointercancel'];

window.randerGraph = (graphContainer, nodes) => {
    // Initialize positions
    var centerX = graphContainer.clientWidth / 2;
    var centerY = graphContainer.clientHeight / 2;

    for (let i = 0; i < nodes.length; i++) {
        const node = nodes[i];
        node.x = centerX + (Math.random() - 0.5) * graphContainer.clientWidth * 0.8;
        node.y = centerY + (Math.random() - 0.5) * graphContainer.clientHeight * 0.8;
        node.vx = 0;
        node.vy = 0;
    };

    // Create DOM elements for nodes and links
    const nodeElements = {};
    const linkElements = [];

    function createGraph() {
        // Clear existing elements
        graphContainer.innerHTML = '';
        linkElements.length = 0;

        // Create links first (so they appear behind nodes)
        nodes.forEach(sourceNode => {
            if (sourceNode.links) {
                sourceNode.links.forEach(targetId => {
                    const targetNode = nodes.find(n => n.id === targetId);
                    if (targetNode) {
                        const link = document.createElement('div');
                        link.className = 'link';
                        graphContainer.appendChild(link);
                        linkElements.push({
                            element: link,
                            source: sourceNode,
                            target: targetNode
                        });
                    }
                });
            }
        });

        // Create nodes
        nodes.forEach(node => {
            const nodeElement = document.createElement('div');
            nodeElement.className = 'node';
            nodeElement.textContent = node.name ?? node.id;
            nodeElement.nid = node.id;
            nodeElement.style.width = `${node.size}px`;
            nodeElement.style.height = `${node.size}px`;
            nodeElement.style.color = node.color;
            nodeElement.style.backgroundColor = node.backgroundColor;
            nodeElement.style.left = `${node.x - node.size / 2}px`;
            nodeElement.style.top = `${node.y - node.size / 2}px`;
            nodeElement.style.fontSize = `${Math.max(8, node.size / 5)}px`;
            graphContainer.appendChild(nodeElement);

            nodeElements[node.id] = nodeElement;

            // Add event listeners
            nodeElement.addEventListener(eventList[0], startDrag);
        });

        // Update link positions
        updateLinks();
    }

    // Update link positions based on node positions
    function updateLinks() {
        linkElements.forEach(link => {
            const dx = link.target.x - link.source.x;
            const dy = link.target.y - link.source.y;

            link.element.style.width = Math.sqrt(dx * dx + dy * dy) + 'px';
            link.element.style.left = link.source.x + 'px';
            link.element.style.top = link.source.y + 'px';
            link.element.style.transform = 'rotate(' + Math.atan2(dy, dx) + 'rad)';
        });
    }

    // Physics simulation
    function simulate() {
        // Apply repulsion between all nodes
        for (let i = 0; i < nodes.length; i++) {
            const node = nodes[i];
            for (let j = 0; j < nodes.length; j++) {
                if (i <= j) continue;
                const node2 = nodes[j];
                if (node.links && node.links.includes(node2.id)) continue;

                const dx = node2.x - node.x;
                const dy = node2.y - node.y;

                const distance2 = dx * dx + dy * dy;
                if (distance2 > physicsParams.maxRepulsionDistance2) continue;

                const distance = Math.sqrt(distance2);
                const force = physicsParams.repulsion / distance2;
                const fx = force * dx / distance;
                const fy = force * dy / distance;

                if (!node.fixed) {
                    node.vx -= fx;
                    node.vy -= fy;
                }
                if (!node2.fixed) {
                    node2.vx += fx;
                    node2.vy += fy;
                }
            }

            // Apply attraction for linked nodes
            if (node.links) {
                for (let i = 0; i < node.links.length; i++) {
                    const targetNode = nodes.find(n => n.id === node.links[i]);
                    if (targetNode) {
                        const dx = targetNode.x - node.x;
                        const dy = targetNode.y - node.y;
                        const distance = Math.sqrt(dx * dx + dy * dy);
                        
                        if (distance > 0) {
                            const force = (distance - physicsParams.linkDistance) * physicsParams.linkStrength;

                            const fx = force * dx / distance;
                            const fy = force * dy / distance;

                            if (!node.fixed) {
                                node.vx += fx;
                                node.vy += fy;
                            }
                            if (!targetNode.fixed) {
                                targetNode.vx -= fx;
                                targetNode.vy -= fy;
                            }
                        }
                    }
                }
            }

            if (node.fixed) {
                // 被拖拽的节点
                const dx = node.targetX - node.x;
                const dy = node.targetY - node.y;
                node.vx += dx * physicsParams.dragStrength;
                node.vy += dy * physicsParams.dragStrength;
            } else {
                // Pull toward center
                const dx = centerX - node.x;
                const dy = centerY - node.y;
                node.vx += dx * physicsParams.centerStrength;
                node.vy += dy * physicsParams.centerStrength;
            }

            // Apply velocity with friction
            node.vx *= physicsParams.friction;
            node.vy *= physicsParams.friction;
            node.x += node.vx;
            node.y += node.vy;

            // Boundary checks
            const padding = 35;
            if (node.x < padding) node.vx += padding - node.x
            else if (node.x > graphContainer.clientWidth - padding) node.vx += graphContainer.clientWidth - padding - node.x;
            if (node.y < padding) node.vy += padding - node.y
            else if (node.y > graphContainer.clientHeight - padding) node.vy += graphContainer.clientHeight - padding - node.y;

            // Update DOM position
            if (nodeElements[node.id]) {
                nodeElements[node.id].style.left = node.x - node.size / 2 + 'px';
                nodeElements[node.id].style.top = node.y - node.size / 2 + 'px';
            }
        }

        // Update links
        updateLinks();
    }

    // Animation loop
    function animate() {
        // const st = Date.now();
        simulate();
        // console.log(Date.now() - st);
        requestAnimationFrame(animate);
    }

    // Interaction
    let draggedNode = null;
    let isDragging = false;
    let offsetX, offsetY;

    function startDrag(e) {
        e.preventDefault();
        e.stopPropagation();

        draggedNode = nodes.find(node => node.id === e.target.nid);
        if (draggedNode) {
            isDragging = true;

            graphContainer.querySelectorAll('.node').forEach(ele => {
                if (draggedNode.id === ele.nid) return;
                if (draggedNode.links && draggedNode.links.includes(ele.nid)) return;
                ele.style.filter = 'brightness(.3)';
            });

            const containerRect = graphContainer.getBoundingClientRect();
            const [clientX, clientY] = getclientXY(e);
            offsetX = clientX - containerRect.left - draggedNode.x;
            offsetY = clientY - containerRect.top - draggedNode.y;

            // 设置拖拽状态
            draggedNode.fixed = true;
            draggedNode.targetX = draggedNode.x;
            draggedNode.targetY = draggedNode.y;

            // 视觉反馈
            e.target.classList.add('dragging');

            document.addEventListener(eventList[1], dragNode, { passive: false });
            document.addEventListener(eventList[2], stopDrag);
            document.addEventListener(eventList[3], stopDrag);
        }
    }

    function dragNode(e) {
        e.preventDefault();
        if (isDragging && draggedNode) {
            const containerRect = graphContainer.getBoundingClientRect();
            const [clientX, clientY] = getclientXY(e);
            draggedNode.targetX = clientX - containerRect.left - offsetX;
            draggedNode.targetY = clientY - containerRect.top - offsetY;
        }
    }

    function stopDrag() {
        if (draggedNode) {
            draggedNode.fixed = false;
            delete draggedNode.targetX;
            delete draggedNode.targetY;
            nodeElements[draggedNode.id].classList.remove('dragging');
        }
        graphContainer.querySelectorAll('.node').forEach(ele => ele.style.filter = '');
        isDragging = false;
        draggedNode = null;
        document.removeEventListener(eventList[1], dragNode);
        document.removeEventListener(eventList[2], stopDrag);
        document.removeEventListener(eventList[3], stopDrag);
    }

    function getclientXY(e) {
        return isTouch ? [e.touches[0].clientX, e.touches[0].clientY] : [e.clientX, e.clientY];
    }

    // Handle window resize
    window.addEventListener('resize', () => {
        centerX = graphContainer.clientWidth / 2;
        centerY = graphContainer.clientHeight / 2;

        // Adjust nodes that might be outside new boundaries
        nodes.forEach(node => {
            if (node.x < 0) node.x = 0;
            if (node.x > graphContainer.clientWidth) node.x = graphContainer.clientWidth;
            if (node.y < 0) node.y = 0;
            if (node.y > graphContainer.clientHeight) node.y = graphContainer.clientHeight;
        });
    });

    // Initialize and start animation
    createGraph();
    animate();
}