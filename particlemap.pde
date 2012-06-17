float width = window.innerWidth;
float height = window.innerHeight;

class SubNode {
    int x, y;
    int w, h;
    ArrayList particles; // list of particles
    ArrayList to;

    SubNode(int x, int y) {
        this.x = x;
        this.y = y;
        this.w = 40;
        this.h = 40;
        this.particles = new ArrayList();
        this.to = new ArrayList();
    }

    float distance(SubNode to) {
        return( sqrt(pow(this.x-to.x, 2) + pow(this.y-to.y, 2)) );
    }

    void addParticles(int numParticles) {
        for (int j=0; j<numParticles; j++) {
            this.particles.add(new Particle(this.x, this.y));
        }
    }

    void draw() {
        ellipse(this.x, this.y, this.w, this.h);
    }

}

////////////////////////////////////////////////// Node
class Node {
    ArrayList subNodes;
    int sendDuration; // how many time we need to send (in ticks)
    Node to; // destination node
    boolean initial;

    // internal node group
    Node (int sendDuration, ArrayList subNodes) {
        this.sendDuration = sendDuration;
        this.subNodes = subNodes;
        this.initial = false;
    }

    // initial node
    Node (int x, int y, int totalParticles, int sendDuration) {
        this.sendDuration = sendDuration;
        this.subNodes = new ArrayList();
        this.subNodes.add(new SubNode(x, y));
        this.subNodes.get(0).addParticles(totalParticles);
        this.initial = true;
    }

    void connect(Node to) {
        this.to = to;
        // connect each subnode to each to-subnode
        for (int i=0; i<this.subNodes.size(); i++) {
            for (int j=0; j<to.subNodes.size(); j++) {
                this.subNodes.get(i).to.add(to.subNodes.get(j));
            }
        }
    }

    void draw() {
        for (int i=0; i<this.subNodes.size(); i++) {
            this.subNodes.get(i).draw();
        }
    }
}

///////////////////////////////////////////////// Particle
class Particle {
    int x, y;
    int w, h;
    int lastTick;
    
    Particle(int x, int y) {
        this.x = x;
        this.y = y;
        this.w = 10;
        this.h = 10;
        this.lastTick = 0;
    }

    void draw() {
        ellipse(this.x, this.y, this.w, this.h);
    }
}

//////////////////////////////////////////////// Parameters (FIXME: JSON)
int animationVelocity = 10; // 10 frames per second
int tickDuration = 10;      // each clock tick has 10 frames

//////////////////////////////////////////////// Main
ArrayList nodes;
int tick = 0;
int lastTick = 0;
 
void setup() {
    size(width, height);
    frameRate(animationVelocity);

    // building the graph (FIXME: JSON)
    nodes = new ArrayList();
    // A: initial node
    nodes.add(new Node(width/2-100, height/2, 10, 2));

    // B: B1, B2
    ArrayList subNodes = new ArrayList();
    subNodes.add(new SubNode(width/2+100, height/2-100));
    subNodes.add(new SubNode(width/2+100, height/2+100));
    nodes.add(new Node(2, subNodes));

    // node A -> B
    nodes.get(0).connect(nodes.get(1));
}
 
void draw() {
    background(255);

    // draw nodes
    for (int i=0; i<nodes.size(); i++) {
        nodes.get(i).draw();
    }

    // draw particles
    for (int i=0; i<nodes.size(); i++) {
        ArrayList subNodes = nodes.get(i).subNodes;
        for (int j=0; j<subNodes.size(); j++) {
            ArrayList to = subNodes.get(j).to;
            for (int k=0; k<to.size(); k++) {
                // para cada partícula dos subnós alvo
                ArrayList particles = to.get(k).particles;
                for (int l=0; l<particles.size(); l++) {
                    // distância do subnó j até o subnó k
                    float distance = subNodes.get(j).distance(to.get(k));
                    if ((tick - particles.get(l).lastTick) == nodes.get(i).sendDuration) {
                        particles.get(l).lastTick = tick;
                        particles.get(l).x = subNodes.get(j).x;
                    }
                    particles.get(l).x += distance / (nodes.get(i).sendDuration * tickDuration);
                    particles.get(l).draw();
                }
            }
        }
    }

    // update clock
    if (frameCount%tickDuration == 0) {
        tick++;
    }
}
